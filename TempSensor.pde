#include <OneWire.h>

// DS18S20 Temperature chip i/o

OneWire ds(10);  // on pin 10
byte addr[8];
int incomingByte = 0;

void setup(void) {
  // initialize inputs/outputs
  // start serial port
  Serial.begin(9600);
//  Serial.println("Aurduino resatt");

  if ( !ds.search(addr)) {
    ds.reset_search();
    return;
  }

  if ( OneWire::crc8( addr, 7) != addr[7]) {
    Serial.print("CRC is not valid!\n");
    return;
  }
  if ( addr[0] != 0x28) {
    Serial.print("Device is not a DS18S20 family device.\n");
    return;
  }
}

void loop(void) {
  int HighByte, LowByte, TReading, SignBit, Tc_100, Whole, Fract;
  byte i;
  byte data[12];

  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
    if (incomingByte = 65){
      Serial.print(255, BYTE);
    }
  }

  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end

  delay(1000);     // maybe 750ms is enough, maybe not
  // we might do a ds.depower() here, but the reset will take care of it.

  ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad

  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();
  }
  LowByte = data[0];
  HighByte = data[1];
  TReading = (HighByte << 8) + LowByte;
  SignBit = TReading & 0x8000;  // test most sig bit
  if (SignBit) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  Whole = Tc_100 / 100;  // separate off the whole and fractional portions
  Fract = Tc_100 % 100;

  Serial.print(248, BYTE);
  if (SignBit) // If its negative
  {
    Serial.print(1, BYTE);
  } else {
    Serial.print(0, BYTE);
  }
  Serial.print(Whole, BYTE);
//  Serial.print(".");
//  if (Fract < 10)
//  {
//    Serial.print("0");
//  }
  Serial.print(Fract, BYTE);
  delay(60000);
//  Serial.print("\n");
}
