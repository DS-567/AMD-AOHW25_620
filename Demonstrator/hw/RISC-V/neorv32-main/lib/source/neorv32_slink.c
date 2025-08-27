// #################################################################################################
// # << NEORV32: neorv32_slink.c - Stream Link Interface HW Driver >>                              #
// # ********************************************************************************************* #
// # BSD 3-Clause License                                                                          #
// #                                                                                               #
// # Copyright (c) 2023, Stephan Nolting. All rights reserved.                                     #
// #                                                                                               #
// # Redistribution and use in source and binary forms, with or without modification, are          #
// # permitted provided that the following conditions are met:                                     #
// #                                                                                               #
// # 1. Redistributions of source code must retain the above copyright notice, this list of        #
// #    conditions and the following disclaimer.                                                   #
// #                                                                                               #
// # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
// #    conditions and the following disclaimer in the documentation and/or other materials        #
// #    provided with the distribution.                                                            #
// #                                                                                               #
// # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
// #    endorse or promote products derived from this software without specific prior written      #
// #    permission.                                                                                #
// #                                                                                               #
// # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
// # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
// # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
// # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
// # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
// # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
// # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
// # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
// # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
// # ********************************************************************************************* #
// # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
// #################################################################################################


/**********************************************************************//**
 * @file neorv32_slink.c
 * @brief Stream Link Interface HW driver source file.
 **************************************************************************/
#include "neorv32.h"
#include "neorv32_slink.h"


/**********************************************************************//**
 * Check if stream link interface was synthesized.
 *
 * @return 0 if SLINK was not synthesized, 1 if SLINK is available.
 **************************************************************************/
int neorv32_slink_available(void) {

  if (NEORV32_SYSINFO->SOC & (1 << SYSINFO_SOC_IO_SLINK)) {
    return 1;
  }
  else {
    return 0;
  }
}


/**********************************************************************//**
 * Reset, enable and configure SLINK.
 *
 * @param[in] rx_irq Configure RX interrupt conditions (#NEORV32_SLINK_CTRL_enum).
 * @param[in] tx_irq Configure TX interrupt conditions (#NEORV32_SLINK_CTRL_enum).
 **************************************************************************/
void neorv32_slink_setup(uint32_t rx_irq, uint32_t tx_irq) {

  NEORV32_SLINK->CTRL = 0; // reset and disable

  const uint32_t rx_irq_mask = (1 << SLINK_CTRL_IRQ_RX_NEMPTY) |
                               (1 << SLINK_CTRL_IRQ_RX_HALF) |
                               (1 << SLINK_CTRL_IRQ_RX_FULL);
  const uint32_t tx_irq_mask = (1 << SLINK_CTRL_IRQ_TX_EMPTY) |
                               (1 << SLINK_CTRL_IRQ_TX_NHALF) |
                               (1 << SLINK_CTRL_IRQ_TX_NFULL);

  uint32_t tmp = (uint32_t)(1 << SLINK_CTRL_EN);
  tmp |= rx_irq & rx_irq_mask;
  tmp |= tx_irq & tx_irq_mask;

  NEORV32_SLINK->CTRL = tmp;
}


/**********************************************************************//**
 * Clear RX FIFO.
 **************************************************************************/
void neorv32_slink_rx_clear(void) {

  NEORV32_SLINK->CTRL |= 1 << SLINK_CTRL_RX_CLR; // auto-clears
}


/**********************************************************************//**
 * Clear TX FIFO.
 **************************************************************************/
void neorv32_slink_tx_clear(void) {

  NEORV32_SLINK->CTRL |= 1 << SLINK_CTRL_TX_CLR; // auto-clears
}


/**********************************************************************//**
 * Get FIFO depth of RX link.
 *
 * @return FIFO depth of RX link (1..32768).
 **************************************************************************/
int neorv32_slink_get_rx_fifo_depth(void) {

  uint32_t tmp = (NEORV32_SLINK->CTRL >> SLINK_CTRL_RX_FIFO_LSB) & 0x0f;
  return (int)(1 << tmp);
}


/**********************************************************************//**
 * Get FIFO depth of TX link.
 *
 * @return FIFO depth of TX link (1..32768).
 **************************************************************************/
int neorv32_slink_get_tx_fifo_depth(void) {

  uint32_t tmp = (NEORV32_SLINK->CTRL >> SLINK_CTRL_TX_FIFO_LSB) & 0x0f;
  return (int)(1 << tmp);
}


/**********************************************************************//**
 * Read data from RX link (non-blocking)
 *
 * @return Data received from link.
 **************************************************************************/
inline uint32_t __attribute__((always_inline)) neorv32_slink_get(void) {

  return NEORV32_SLINK->DATA;
}


/**********************************************************************//**
 * Check if last RX word has "end-of-stream" delimiter.
 *
 * @note This needs has to be called AFTER reading the actual data word
 * using #neorv32_slink_get(void).
 *
 * @return 0 if not end of stream, !=0 if end of stream.
 **************************************************************************/
inline uint32_t __attribute__((always_inline)) neorv32_slink_check_last(void) {

  return NEORV32_SLINK->CTRL & (1 << SLINK_CTRL_RX_LAST);
}


/**********************************************************************//**
 * Write data to TX link (non-blocking)
 *
 * @param[in] tx_data Data to send to link.
 **************************************************************************/
inline void __attribute__((always_inline)) neorv32_slink_put(uint32_t tx_data) {

  NEORV32_SLINK->DATA = tx_data;
}


/**********************************************************************//**
 * Write data to TX link (non-blocking) and set "last" (end-of-stream)
 * delimiter.
 *
 * @param[in] tx_data Data to send to link.
 **************************************************************************/
inline void __attribute__((always_inline)) neorv32_slink_put_last(uint32_t tx_data) {

  NEORV32_SLINK->DATA_LAST = tx_data;
}


/**********************************************************************//**
 * Get RX link FIFO status.
 *
 * @return FIFO status #NEORV32_SLINK_STATUS_enum.
 **************************************************************************/
int neorv32_slink_rx_status(void) {

  uint32_t tmp = NEORV32_SLINK->CTRL;

  if (tmp & (1 << SLINK_CTRL_RX_FULL)) {
    return SLINK_FIFO_FULL;
  }
  else if (tmp & (1 << SLINK_CTRL_RX_HALF)) {
    return SLINK_FIFO_HALF;
  }
  else if (tmp & (1 << SLINK_CTRL_RX_EMPTY)) {
    return SLINK_FIFO_EMPTY;
  }
  else {
    return -1;
  }
}


/**********************************************************************//**
 * Get TX link FIFO status.
 *
 * @return FIFO status #NEORV32_SLINK_STATUS_enum.
 **************************************************************************/
int neorv32_slink_tx_status(void) {

  uint32_t tmp = NEORV32_SLINK->CTRL;

  if (tmp & (1 << SLINK_CTRL_TX_FULL)) {
    return SLINK_FIFO_FULL;
  }
  else if (tmp & (1 << SLINK_CTRL_TX_HALF)) {
    return SLINK_FIFO_HALF;
  }
  else if (tmp & (1 << SLINK_CTRL_TX_EMPTY)) {
    return SLINK_FIFO_EMPTY;
  }
  else {
    return -1;
  }
}
