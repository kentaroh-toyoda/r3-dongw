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

configuration WatchdogAppC
{

}

implementation
{
    components MainC                as MainC;
    components LedsC                as LedsC;
    components WatchdogAppP         as WatchdogAppP;
    components new WatchdogC()      as WatchdogSendMsgC;
    components new WatchdogC()      as WatchdogSendMsgDoneC;
    components new TimerMilliC()    as SendTimerC;
    components SerialActiveMessageC as SerialActiveMessageC;

    WatchdogAppP.Boot                -> MainC;
    WatchdogAppP.Leds                -> LedsC;
    WatchdogAppP.Packet              -> SerialActiveMessageC;
    WatchdogAppP.UartCtl             -> SerialActiveMessageC;
    WatchdogAppP.UartSend            -> SerialActiveMessageC;
    WatchdogAppP.SendTimer           -> SendTimerC;
    WatchdogAppP.WatchdogSendMsg     -> WatchdogSendMsgC;
    WatchdogAppP.WatchdogSendMsgDone -> WatchdogSendMsgDoneC;

    MainC.SoftwareInit -> WatchdogAppP.Init;
}
