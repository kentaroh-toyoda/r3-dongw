/*
 * Copyright (c) 2007, Ecole Polytechnique Fédérale de Lausanne (EPFL),
 * Audiovisual Communications Laboratory, 1015 Lausanne, Switzerland.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * This file is part of the project SensorScope -- http://sensorscope.epfl.ch
 *
 * @author François Ingelrest
 */

#include <message.h>
#include "pr.h"

#define AM_FOO 100

typedef struct _payload_t
{
    nx_uint16_t counter;
} payload_t;

module WatchdogAppP
{
    provides interface Init;

    uses interface Boot          as Boot;
    uses interface Leds          as Leds;
    uses interface Packet        as Packet;
    uses interface AMSend        as UartSend[am_id_t msgId];
    uses interface Watchdog      as WatchdogSendMsg;
    uses interface Watchdog      as WatchdogSendMsgDone;
    uses interface SplitControl  as UartCtl;
    uses interface Timer<TMilli> as SendTimer;
}

implementation
{
    uint8_t    mTimerCnt;
    uint8_t    mSendMsgCnt;
    message_t  mMsg;
    payload_t *mPayload;

    command error_t Init.init()
    {
        mPayload          = (payload_t*) call Packet.getPayload(&mMsg, TOSH_DATA_LENGTH);
        mPayload->counter = 0;

        mTimerCnt   = 6;  // SendTimer.fired() doesn't send a message when mTimerCnt is equal to 0
        mSendMsgCnt = 5;  // sendMsg() doesn't send a message when mSendMsgCnt is equal to 0

        return SUCCESS;
    }

    task void startUart()
    {
        if(call UartCtl.start() != SUCCESS)
            post startUart();
    }

    event void UartCtl.startDone(error_t err)
    {
        if(err != SUCCESS)
            post startUart();
        else
        {
            call SendTimer.startPeriodic(2048);      // Try to send a mesage every 2 seconds
            call WatchdogSendMsg.enable(2560);       // Allow for a slight delay
            call WatchdogSendMsgDone.enable(2560);   // Allow for a slight delay
        }
    }

    event void UartCtl.stopDone(error_t err)
    {
        // Unused
    }

    event void Boot.booted()
    {
        post startUart();
        pr("Booted\n");
    }

    task void sendMsg()
    {
        call WatchdogSendMsg.touch();

        // Stop sending messages?
        if(mSendMsgCnt != 0)
        {
        	  pr("start send msg\n");
            --mSendMsgCnt;
            if(call UartSend.send[AM_FOO](AM_BROADCAST_ADDR, &mMsg, sizeof(payload_t)) != SUCCESS)
                post sendMsg();
        }
    }

    event void UartSend.sendDone[am_id_t msgId](message_t *msg, error_t err)
    {
        call WatchdogSendMsgDone.touch();
        call Leds.led1Toggle();
    }

    event void SendTimer.fired()
    {
        call Leds.led2Toggle();

        // Stop sending messages?
        if(mTimerCnt != 0)
        {
            pr("post send task\n");
            --mTimerCnt;
            ++mPayload->counter;
            post sendMsg();
        }
    }

    event void WatchdogSendMsg.fired(bool guilty)
    {
        // guilty is TRUE if WatchdogSendMsg did not met its deadline
    }

    event void WatchdogSendMsgDone.fired(bool guilty)
    {
        // guilty is TRUE if WatchdogSendMsgDone did not met its deadline
    }
}
