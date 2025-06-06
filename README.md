# ARMDeviceDrivers


This repo contains all the drivers I've written for the below list :

1) Analog-to-Digital Converter drivers
2) I2C drivers 
3) UART drivers 
4) TIMER drivers
6) GPIO drivers


Our Simpler project includes GPIODriver 1,2,3 are Output Drivers (where we turn on the LED and also toggle it to make it blink) and GPIODriver 4 is the Input Driver (where we drive a LED using the onboard push button)

Our UART Transmitter Driver sends a bunch of characters via the serial port, to view them, I used Minicom for Linux, but for Windows, we can use Tera Term

Initialized GPIO-B pin for I2C alternate function and sends a byte 0x55 to a slave device with address 0x3C.

The ADC code configures ADC1 on STM32F411 to read analog input from pin PA1 and continuously converts it to a digital value. It then transmits 12-bit ADC values over UART (PA2) to whatever serial terminal connected.

The TIMER driver toggles LED connected to PA5 on board at 1 Hz using TIM2 configured as a 1-second timer, enabling GPIOA and TIM2 clocks, sets PA5 as output, configures TIM2 with a prescaler and auto-reload, and toggles PA5 on every timer update.

The SysTick initializes PA5 and uses the SysTick timer to blink the LED on and off every 1 second.

The UART transmitter configures USART2 on pin PA2 to transmit data at 9600 baud (8-bit, 1 stop also I've ignored flow control).

The UART reciever configures USART2(PA2 as TX and PA3 as RX) for 8-bit data, 1 stop bit, 115200 baud rate, receives characters via UART,  blinks an LED(PA5) if the received character is ASCII '1'.

The UART implements a full USART2 TX/RX interface, using GPIOA (PA2 for Tx, PA3 for Rx), with an LED blink on receiving the character '1'. It includes peripheral clock enabling, pin mode settings, UART initialization, and simple character I/O with a delay loop for LED control.

The interrupt driver UART does the following : 

  1) CPU sends first byte and rest are sent from a buffer inside the ISR whenever the UART is ready.
  2) Eliminates the need for constant polling of the TXE flag, avoids processor idling.

# Note

I suggest if you're interested to follow along, refer the Driver Dev section in the ARM Assembly notes upload :)


# Toolkits/Boards 

1) Keil uVision 5 IDE
2) STM32F411-NUCLEO/STM32F4-DISCOVERY

