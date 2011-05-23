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

#include "Watchdog.h"

generic module WatchdogImplP(uint8_t NB_WATCHDOGS)
{
    provides interface Init;
    provides interface Watchdog[uint8_t id];

    uses interface Timer<TMilli>     as WatchdogTimer;
    uses interface LocalTime<TMilli> as LocalTime;
}

implementation
{
    uint8_t    mEnabledCnt;
    wd_entry_t mWatchdogs[NB_WATCHDOGS];

    default event void Watchdog.fired[uint8_t id](bool guilty) {}

    command error_t Init.init()
    {
        uint8_t i;

        mEnabledCnt = 0;
        for(i=0; i<NB_WATCHDOGS; ++i)
            mWatchdogs[i].enabled = FALSE;

        return SUCCESS;
    }

    command void Watchdog.touch[uint8_t id]()
    {
        mWatchdogs[id].timestamp = call LocalTime.get();
    }

    command void Watchdog.changeDeadline[uint8_t id](uint32_t deadline)
    {
        mWatchdogs[id].deadline  = deadline;
        mWatchdogs[id].timestamp = call LocalTime.get();
    }

    command void Watchdog.enable[uint8_t id](uint32_t deadline)
    {
        call Watchdog.changeDeadline[id](deadline);

        if(mWatchdogs[id].enabled == FALSE)
        {
            mWatchdogs[id].enabled = TRUE;

            if(++mEnabledCnt == 1)
            {
                START_WATCHDOG();
                call WatchdogTimer.startPeriodic(900);
            }
        }
    }

    command void Watchdog.disable[uint8_t id]()
    {
        if(mWatchdogs[id].enabled == TRUE)
        {
            mWatchdogs[id].enabled = FALSE;

            if(--mEnabledCnt == 0)
            {
                STOP_WATCHDOG();
                call WatchdogTimer.stop();
            }
        }
    }

    event void WatchdogTimer.fired()
    {
        uint8_t  i;
        uint8_t  j;
        uint32_t now;
        uint32_t elapsed;

        // Make sure that there are still some active watchdogs
        if(mEnabledCnt == 0)
            return;

        now = call LocalTime.get();

        for(i=0; i<NB_WATCHDOGS; ++i)
        {
            if(mWatchdogs[i].enabled == TRUE)
            {
                // Overflows of the local time should be transparent on unsigned integers
                elapsed = now - mWatchdogs[i].timestamp;

                // If too much time has elapsed, reboot the mote
                if(elapsed >= mWatchdogs[i].deadline)
                {
                    STOP_WATCHDOG();

                    // Warn all watchdog modules
                    // Suggested by Maxime Muller (Shockfish)
                    for(j=0; j<NB_WATCHDOGS; ++j)
                        signal Watchdog.fired[j](j == i ? TRUE : FALSE);

                    REBOOT_NOW();
                }
            }
        }

        RESET_WATCHDOG();
    }
}
