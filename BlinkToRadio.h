#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

typedef nx_struct blink_to_radio_msg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} blink_to_radio_msg_t;

enum {
  AM_BLINKTORADIO = 8,
  TIMER_PERIOD_MILLI = 250
};

#endif
