//
// Created by luedi on 8/1/25.
//
#include "memory.h"


// Simple console output function for testing
void print_string(const char* str) {
    char* video_memory = (char*)0xB8000;
    static int cursor_pos = 0;
    
    while (*str) {
        video_memory[cursor_pos * 2] = *str;
        video_memory[cursor_pos * 2 + 1] = 0x07;  // Light gray on black
        cursor_pos++;
        str++;
    }
}

void print_hex(unsigned int value) {
    char buffer[11] = "0x00000000";
    const char hex_chars[] = "0123456789ABCDEF";
    
    for (int i = 9; i >= 2; i--) {
        buffer[i] = hex_chars[value & 0xF];
        value >>= 4;
    }
    
    print_string(buffer);
}

void print_test_result(const char* test_name, int passed) {
    print_string(test_name);
    print_string(": ");
    if (passed) {
        print_string("PASSED\n");
    } else {
        print_string("FAILED\n");
    }
}

// Memory test functions
int test_memcopy_basic() {
    char src[] = "Hello, World!";
    char dest[20];
    
    // Clear destination buffer
    for (int i = 0; i < 20; i++) {
        dest[i] = 0;
    }
    
    // Test basic copy
    memcopy(dest, src, 14);
    
    // Verify copy
    for (int i = 0; i < 14; i++) {
        if (dest[i] != src[i]) {
            return 0;  // Test failed
        }
    }
    
    return 1;  // Test passed
}

int test_memcopy_overlap() {
    char buffer[30] = "ABCDEFGHIJKLMNOP";
    
    // Test overlapping copy (dest > src)
    memcopy(buffer + 5, buffer, 10);
    
    // Check if first 10 chars are copied to position 5
    for (int i = 0; i < 10; i++) {
        if (buffer[i + 5] != "ABCDEFGHIJ"[i]) {
            return 0;
        }
    }
    
    return 1;
}

int test_memcopy_zero_length() {
    char src[] = "Test";
    char dest[10] = "Original";
    
    // Copy zero bytes
    memcopy(dest, src, 0);
    
    // Destination should remain unchanged
    if (dest[0] != 'O' || dest[1] != 'r') {
        return 0;
    }
    
    return 1;
}

int test_memcopy_large_block() {
    unsigned char src[256];
    unsigned char dest[256];
    
    // Initialize source with pattern
    for (int i = 0; i < 256; i++) {
        src[i] = i & 0xFF;
        dest[i] = 0;
    }
    
    // Copy large block
    memcopy(dest, src, 256);
    
    // Verify all bytes copied correctly
    for (int i = 0; i < 256; i++) {
        if (dest[i] != (i & 0xFF)) {
            return 0;
        }
    }
    
    return 1;
}

int test_memcopy_alignment() {
    // Test unaligned addresses
    char buffer[100];
    char* src = buffer + 1;   // Unaligned source
    char* dest = buffer + 51;  // Unaligned destination
    
    // Fill source with test pattern
    for (int i = 0; i < 20; i++) {
        src[i] = 'A' + i;
    }
    
    // Clear destination
    for (int i = 0; i < 20; i++) {
        dest[i] = 0;
    }
    
    // Copy with unaligned addresses
    memcopy(dest, src, 20);
    
    // Verify copy
    for (int i = 0; i < 20; i++) {
        if (dest[i] != src[i]) {
            return 0;
        }
    }
    
    return 1;
}

void kernel_main(void) {
//    // Clear screen first
//    char* video_memory = (char*)0xB8000;
//    for (int i = 0; i < 80 * 25 * 2; i += 2) {
//        video_memory[i] = ' ';
//        video_memory[i + 1] = 0x07;
//    }
//
//    print_string("=== Memory Test Suite ===\n\n");
//
//    // Run tests
//    print_test_result("Basic memcopy test", test_memcopy_basic());
//    print_test_result("Overlapping memcopy test", test_memcopy_overlap());
//    print_test_result("Zero-length memcopy test", test_memcopy_zero_length());
//    print_test_result("Large block memcopy test", test_memcopy_large_block());
//    print_test_result("Unaligned memcopy test", test_memcopy_alignment());
//
//    print_string("\n=== Tests Complete ===\n");
//
//    // Test direct memory write
//    print_string("\nTesting direct memory write at 0x100000...\n");
//    *(char*)0x100000 = 0xFF;
//    unsigned char value = *(char*)0x100000;
//    print_string("Value at 0x100000: ");
//    print_hex(value);
//    print_string("\n");
//
    int a = 10;
    // Halt
    while(1);
}