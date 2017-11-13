#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {

  uint16_t counter = 0;  
  message_t pkt;
  bool busy = FALSE;
  

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      dbg("Boot", "Radio Started.\n");    
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    dbg("BlinkToRadioC", "In node %hhu%s%hhu \n", TOS_NODE_ID, " counter = ", counter);
    counter++;  
    call Leds.set(counter);  
    if (!busy) {
      blink_to_radio_msg_t* btrpkt = 
	(blink_to_radio_msg_t*)(call Packet.getPayload(&pkt, sizeof(blink_to_radio_msg_t)));      
      if (btrpkt == NULL) {
		return;
      }      
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;      
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(blink_to_radio_msg_t)) == SUCCESS) {        
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {	
    if (&pkt == msg) {      
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){          
    if (len == sizeof(blink_to_radio_msg_t)) {
      blink_to_radio_msg_t* btrpkt = (blink_to_radio_msg_t*)payload;            
      dbg_clear("BlinkToRadioC", "node %hhu%s%hhu \n", TOS_NODE_ID, " from ", btrpkt->nodeid);          	      
    }
    return msg;
  }
}
