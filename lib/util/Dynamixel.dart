import 'dart:typed_data';
import 'CRC16.dart';

enum PKT {
  HEADER0, //  0
  HEADER1, //  1
  HEADER2, //  2
  RESERVED, //  3
  ID, //  4
  LENGTH_L, //  5
  LENGTH_H, //  6
  INSTRUCTION, //  7
  PARAMETER //  8
}

class Dynamixel {
  static final int INST_PING = 1;
  static final int INST_READ = 2;
  static final int INST_WRITE = 3;
  static final int INST_REG_WRITE = 4;
  static final int INST_ACTION = 5;
  static final int INST_RESET = 6;
  static final int INST_STATUS = 85; // 0x55
  static final int INST_READ_STREAM = 114; // 0x72
  static final int INST_WRITE_STREAM = 115; // 0x73
  static final int INST_SYNC_READ = 130; // 0x82
  static final int INST_SYNC_WRITE = 131; // 0x83
  static final int INST_BULK_READ = 146; // 0x92
  static final int INST_BULK_WRITE = 147; // 0x93

  static final int MAXNUM_TXPARAM = 500;
  static final int MAXNUM_RXPARAM = 500;

  static final int ERRBIT_VOLTAGE = 1;
  static final int ERRBIT_ANGLE = 2;
  static final int ERRBIT_OVERHEAT = 4;
  static final int ERRBIT_RANGE = 8;
  static final int ERRBIT_CHECKSUM = 16;
  static final int ERRBIT_OVERLOAD = 32;
  static final int ERRBIT_INSTRUCTION = 64;

  static final int DEFAULT_STATUS_PACKET_LENTH =
      11; // lenth of single status packet includes param0;

  final int DEFAULT_DELAY = 500;

  static int getLowByte(int a) {
    // return 1 byte
    return (a & 0xff);
  }

  static int getHighByte(int a) {
    // return 1 byte
    return ((a >> 8) & 0xff);
  }

  static int makeWord(int a, int b) {
    // 4 -> 1 -> return 2 byte
    return ((a & 0xff) | ((b & 0xff) << 8));
  }

  static List<int> writeBytePacket(int id, int address, int value) {
    List<int> buffer = []..length = 13;

    buffer[PKT.HEADER0.index] = 0xff;
    buffer[PKT.HEADER1.index] = 0xff;
    buffer[PKT.HEADER2.index] = 0xfd;
    buffer[PKT.RESERVED.index] = 0x00;
    buffer[PKT.ID.index] = id;
    buffer[PKT.LENGTH_L.index] = 0x06;
    buffer[PKT.LENGTH_H.index] = 0x00;
    buffer[PKT.INSTRUCTION.index] = INST_WRITE;
    buffer[PKT.PARAMETER.index] = getLowByte(address);
    buffer[PKT.PARAMETER.index + 1] = getHighByte(address);
    buffer[PKT.PARAMETER.index + 2] = value;
    int crc = CRC16.update_crc(
        0,
        buffer,
        makeWord(buffer[PKT.LENGTH_L.index], buffer[PKT.LENGTH_H.index]) +
            PKT.LENGTH_H.index +
            1 -
            2);
    buffer[PKT.PARAMETER.index + 3] = getLowByte(crc);
    buffer[PKT.PARAMETER.index + 4] = getHighByte(crc);
    return buffer;
  }

  static List<int> readPacket(int id, int address, int lengthToRead) {
    List<int> buffer = []..length = 14;

    buffer[PKT.HEADER0.index] = 0xff;
    buffer[PKT.HEADER1.index] = 0xff;
    buffer[PKT.HEADER2.index] = 0xfd;
    buffer[PKT.RESERVED.index] = 0x00;
    buffer[PKT.ID.index] = id;
    buffer[PKT.LENGTH_L.index] = 0x07;
    buffer[PKT.LENGTH_H.index] = 0x00;
    buffer[PKT.INSTRUCTION.index] = INST_READ;
    buffer[PKT.PARAMETER.index] = getLowByte(address);
    buffer[PKT.PARAMETER.index + 1] = getHighByte(address);
    buffer[PKT.PARAMETER.index + 2] = getLowByte(lengthToRead);
    buffer[PKT.PARAMETER.index + 3] = getHighByte(lengthToRead);

    int crc = CRC16.update_crc(
        0,
        buffer,
        makeWord(buffer[PKT.LENGTH_L.index], buffer[PKT.LENGTH_H.index]) +
            PKT.LENGTH_H.index +
            1 -
            2);
    buffer[PKT.PARAMETER.index + 4] = getLowByte(crc);
    buffer[PKT.PARAMETER.index + 5] = getHighByte(crc);

    return buffer;
  }
}
