//
// Created by luedi on 25-7-30.
//

#include "floppy.h"
#include "log.h"
#include <stdlib.h>
#include <memory.h>

Floppy* createFloppy(){
    Floppy* floppy = calloc(1, sizeof(Floppy));
    if (!floppy){ log_error("floppy create error 1");}
    floppy->size = FLOPPY_SIDES * FLOPPY_TRACKS * FLOPPY_SECTORS * 512;
    floppy->data = calloc(1, floppy->size);
    if (!floppy->data){ log_error("floppy create error 2");}
    return floppy;
}

void writeFloppy(Floppy* f, Fileinfo* file, int side, int track, int sector){
    //                            sector begin from 1    every sector has 512 byte
    //             base_address + (sector - 1)*512
    char* offset = f->data + (side * FLOPPY_TRACKS + track) * FLOPPY_SECTORS + (sector- 1) * 512;

    memcpy(offset, file->content, file->size);

    log_info("write:%s",file->name);
}

void exportFloppy(Floppy* f, char* name){
    if (NULL == name || NULL == f) {
        log_error("NULL pointer");
        return;
    }

    FILE* file = fopen(name, "w+");
    if (NULL == file) {
        perror("fopen fail");
        exit(-1);
    }

    fwrite(f->data, 1, f->size, file);

    log_info("export:%s",name);
}


Fileinfo* read_file(const char* filename) {
    if (NULL == filename) {
        return NULL;
    }

    // 1 创建对象
    Fileinfo* fileinfo = calloc(1, sizeof(Fileinfo));
    if (NULL == fileinfo) {
        perror("calloc fail: ");
        exit(-1);
    }

    fileinfo->name = filename;

    // 2 打开文件
    FILE* file = NULL;
    if (NULL == (file = fopen(filename, "rb"))) {
        perror("fopen fail");
        exit(1);
    }

    // 3 获取文件大小
    if (0 != fseek(file, 0, SEEK_END)) {
        perror("fseek fail");
        exit(1);
    }

    fileinfo->size = (int)ftell(file);
    if (-1 == fileinfo->size) {
        perror("ftell fail");
        exit(1);
    }

    // 文件指针还原
    fseek(file, 0, SEEK_SET);

    // 4 申请内存
    fileinfo->content = calloc(1, fileinfo->size);
    if (NULL == fileinfo->content) {
        perror("calloc fail: ");
        exit(-1);
    }

    // 5 文件读入
    int readsize = fread(fileinfo->content, sizeof(char), fileinfo->size, file);
    if (readsize != fileinfo->size) {
        perror("fread fail: ");
        exit(-1);
    }

    // 6 关闭文件
    fclose(file);

    return fileinfo;
}