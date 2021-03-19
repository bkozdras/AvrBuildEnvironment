/**********************************************************************************/
/* Copyright by @bkozdras <b.kozdras@gmail.com>                                   */
/* Purpose: Facade for AVR ATMega328p operations with registers and interrupts.   */
/* Version: 1.0                                                                   */
/* Licence: MIT                                                                   */
/**********************************************************************************/

#ifndef C_EXAMPLE_PROJECT_AVR_REGISTER_CONTROLLER_ATMEGA328P_REGISTERS_H_
#define C_EXAMPLE_PROJECT_AVR_REGISTER_CONTROLLER_ATMEGA328P_REGISTERS_H_

#include <stdint.h>

typedef enum _TBoolean
{
    false = 0,
    true = 1
} TBoolean;

void ATmega328pController_gpioSetHighLevel(const uint8_t port, const uint8_t pin);
void ATmega328pController_gpioSetLowLevel(const uint8_t port, const uint8_t pin);

TBoolean ATmega328pController_gpioIsHighLevel(const uint8_t port, const uint8_t pin);
TBoolean ATmega328pController_gpioIsLowLevel(const uint8_t port, const uint8_t pin);

void ATMega328pController_gpioSetDirectionInput(const uint8_t port, const uint8_t pin);
void ATMega328pController_gpioSetDirectionOutput(const uint8_t port, const uint8_t pin);

#endif // C_EXAMPLE_PROJECT_AVR_REGISTER_CONTROLLER_ATMEGA328P_REGISTERS_H_
