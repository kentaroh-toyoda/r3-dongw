// $Id: TosBootC.nc,v 1.1 2009/09/23 18:29:21 razvanm Exp $

/*
 *
 *
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * @author Jonathan Hui <jwhui@cs.berkeley.edu>
 */

#include <Deluge.h>
#include <DelugePageTransfer.h>
#include "TosBoot.h"

configuration TosBootC {
}
implementation {

  components
    TosBootP,
    ExecC,
    ExtFlashC,
    HardwareC,
    InternalFlashC as IntFlash,
    LedsC,
    PluginC,
    ProgFlashC as ProgFlash,
    VoltageC;

  TosBootP.SubInit -> ExtFlashC;
  TosBootP.SubControl -> ExtFlashC.StdControl;
  TosBootP.SubControl -> PluginC;

  TosBootP.Exec -> ExecC;
  TosBootP.ExtFlash -> ExtFlashC;
  TosBootP.Hardware -> HardwareC;
  TosBootP.IntFlash -> IntFlash;
  TosBootP.Leds -> LedsC;
  TosBootP.ProgFlash -> ProgFlash;
  TosBootP.Voltage -> VoltageC;
  

}
