//
// Created by luedi on 25-7-30.
//

#ifndef LUEDI_OS_FLOPPY_H
#define LUEDI_OS_FLOPPY_H

#define FLOPPY_SIDES 2
#define FLOPPY_TRACKS 80
#define FLOPPY_SECTORS 18
typedef struct {
    char*   name;
    int     size;
    char*   content;
}Fileinfo;


typedef struct s_Floppy{
    int     size;
    char*   data;
} Floppy;

/**
 * @brief create a new instance of floppy
 * @return Floppy instance
 */
Floppy* createFloppy();

/**
 * @brief write data into Floppy
 * @param f Floppy instance
 * @param data content
 * @param sides
 * @param tracks
 * @param sectors
 */
void writeFloppy(Floppy* f, Fileinfo* file, int side, int track, int sector);

/**
 * @brief export Floppy
 * @param f Floppy instance
 * @param name file name
 */
void exportFloppy(Floppy* f, char* name);
/*
 * FILE
 */

Fileinfo* read_file(const char* filename);
#endif //LUEDI_OS_FLOPPY_H
