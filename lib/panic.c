// Copyright (C) strawberryhacker

#include <citrus/panic.h>
#include <citrus/print.h>
#include <citrus/regmap.h>

void assert_handler(const char* file, u32 line, u32 statement)
{
    if (!statement) {
        panic_handler(file, line, "Assertion failed");
    }
}

void panic_handler(const char* file, u32 line, const char* reason)
{
    print("Panic! at line %d in file ", line);
    print(file);
    print("\nReason: ");
    print(reason);
    print("\n");

    // Flush the serial buffer
    while (!(UART1->SR & (1 << 9)));
    RST->CR = 0xA5000000 | 1;
}
