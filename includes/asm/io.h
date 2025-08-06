

#pragma once
/// \brief Read a byte from a io port.
/// \param port io port e.g. 0x1F2.
/// \return The byte read from the io port.
char in_byte(int port);
/// \brief Read a word(2 bytes) from a io port.
/// \param port io port e.g. 0x1F7.
/// \return The word(2 bytes) read from the io port.
short in_word(int port);

/// \brief Write a byte to a io port.
/// \param port io port e.g. 0x1F2.
/// \param v The byte to write to the io port.
void out_byte(int port, int v);
/// \brief Write a word(2 bytes) to a io port.
/// \param port io port e.g. 0x1F7.
/// \param v The word(2 bytes) to write to the io port.
void out_word(int port, int v);


