
#include "cc2500_REG.h"
#include "cc2500_VAL.h"

#define CC2500_IDLE    0x36      // Exit RX / TX, turn
#define CC2500_TX      0x35      // Enable TX. If in RX state, only enable TX if CCA passes
#define CC2500_RX      0x34      // Enable RX. Perform calibration if enabled
#define CC2500_FTX     0x3B      // Flush the TX FIFO buffer. Only issue SFTX in IDLE or TXFIFO_UNDERFLOW states
#define CC2500_FRX     0x3A      // Flush the RX FIFO buffer. Only issue SFRX in IDLE or RXFIFO_OVERFLOW states
#define CC2500_TXFIFO  0x3F
#define CC2500_RXFIFO  0x3F

#define No_of_Bytes    3
int PacketLength=0;
int rssi=0, lqi=0;
char data1, data2;

// For Arduino
#include <SPI.h>
const int GDO0_PIN = 4;     // the number of the GDO0_PIN pin
int GDO0_State = 0;         // variable for reading the pushbutton status

//For ATtiny85
/*
//#include "SPI85.h" // #include things should be commented with double slash to really get disabled!
const static uint8_t MISO = PB0;
const static uint8_t MOSI = PB1;
const static uint8_t SCK  = PB2;
const static uint8_t SS   = PB4;
const static uint8_t GDO0_PIN = PB3;     // the number of the GDO0_PIN pin
int GDO0_State = 0;
*/

void setup()
{              
        // For Arduino 
        Serial.begin(9600);
        
        pinMode(SS,OUTPUT);

        // For Arduino 
        SPI.begin();
        //For ATtiny85
        //SPI85.begin();
       
        digitalWrite(SS,HIGH);
        pinMode(GDO0_PIN, INPUT);     
        init_CC2500();
        Read_Config_Regs();
   
        // For Arduino         
        Serial.println("Starting..");
}

void loop()
{        
        delay(10);
        send_packet(No_of_Bytes); 
        delay(500);           
        //recv_packet();       
}

void send_packet(unsigned char length)
{
      // Make sure that the radio is in IDLE state before flushing the FIFO
      SendStrobe(CC2500_IDLE);
      // Flush TX FIFO
      SendStrobe(CC2500_FTX);

      // prepare Packet
      unsigned char packet[length];
      // First Byte = Length Of Packet
      packet[0] = length;
      packet[1] = 0x05;
      packet[2] = 0x06;      
      
      // SIDLE: exit RX/TX
      SendStrobe(CC2500_IDLE);
      
      for(int i = 0; i < length; i++)
      {	  
              WriteReg(CC2500_TXFIFO,packet[i]);
      }
      // STX: enable TX
      SendStrobe(CC2500_TX);
      
      // Wait for GDO0 to be set -> sync transmitted
      while (!GDO0_State)
      {
          // read the state of the GDO0_PIN value:
          GDO0_State = digitalRead(GDO0_PIN);          
          //Serial.println("GD0 = 1");
       }
       
       // Wait for GDO0 to be cleared -> end of packet
       while (GDO0_State)
       {
           // read the state of the GDO0_PIN value:
           GDO0_State = digitalRead(GDO0_PIN);
           //Serial.println("GD0 = 1");
       }
}

void recv_packet(void) 
{    
        PacketLength=0;
        // RX: enable RX
        SendStrobe(CC2500_RX);

        GDO0_State = digitalRead(GDO0_PIN);
        //    Serial.println("GDO0");
        //    Serial.println(GDO0_State);
        
        //#Asanka
        if(GDO0_State) {
                Serial.println("GDO0_State already HIGH");
                delay(500);
                SendStrobe(CC2500_IDLE);
                SendStrobe(CC2500_FRX);
                delay(2000);
                return;
        }
    
        // Wait for GDO0 to be set -> sync received
        while (!GDO0_State) {
                // read the state of the GDO0_PIN value:
                GDO0_State = digitalRead(GDO0_PIN);
                //Serial.println("GD0 = 0");
                //#Asanka: decresed the delay
                //delay(100);
                delay(10);
        }
    
        // Wait for GDO0 to be cleared -> end of packet
        while (GDO0_State) {
                // read the state of the GDO0_PIN value:
                GDO0_State = digitalRead(GDO0_PIN);
                //Serial.println("GD0 = 1");
                //#Asanka: decresed the delay
                //delay(100);
                delay(10);
        }
        
        //char data1, data2;
        // Read length byte
        PacketLength = ReadReg(CC2500_RXFIFO);        
          
        if(No_of_Bytes == PacketLength)
        {                                
                Serial.println("---------------------");
                Serial.print("Packet Received, length= ");
                Serial.println(PacketLength,HEX);                
                
                Serial.print("Data: ");
                data1 = ReadReg(CC2500_RXFIFO);
                data2 = ReadReg(CC2500_RXFIFO);                    
                Serial.print(data1,HEX);
                //delay(10);
                Serial.println(data2,HEX);                                                
                Serial.println("---------------------");
                
        } else {                        
                /*
                Serial.println("---------------------");
                Serial.print("Received some junk, length= ");
                Serial.println(PacketLength,HEX);                
                Serial.println("---------------------");                
                */
        }
         
        // Make sure that the radio is in IDLE state before flushing the FIFO
        // (Unless RXOFF_MODE has been changed, the radio should be in IDLE state at this point) 
        SendStrobe(CC2500_IDLE);
        // Flush RX FIFO
        SendStrobe(CC2500_FRX);                               

        if(No_of_Bytes == PacketLength) {
                
                rssi = ReadReg(REG_RSSI);
                lqi = ReadReg(REG_LQI);                              
                
                Serial.print("RSSI: ");          
                Serial.println(rssi);
                Serial.print("LQI: ");          
                Serial.println(lqi);                                 
        }
}
	

void WriteReg(char addr, char value) {
        digitalWrite(SS,LOW);
  
        while (digitalRead(MISO) == HIGH) {
        };

        // For Arduino 
        SPI.transfer(addr);        
        // For ATtiny85
        //SPI85.transfer(addr);
        
        delay(10);
        
        // For Arduino 
        SPI.transfer(value);
        // For ATtiny85
        //SPI85.transfer(value);
                
        digitalWrite(SS,HIGH);
}

char ReadReg(char addr) {
        addr = addr + 0x80;
        digitalWrite(SS,LOW);
        while (digitalRead(MISO) == HIGH) {
        };
        
        // For Arduino 
        char x = SPI.transfer(addr);
        // For ATtiny85
        //char x = SPI85.transfer(addr);
       
        delay(10);

        // For Arduino         
        char y = SPI.transfer(0);        
        // For ATtiny85
        //char y = SPI85.transfer(0);
        
        digitalWrite(SS,HIGH);
        return y;  
}

char SendStrobe(char strobe) {
        digitalWrite(SS,LOW);
  
        while (digitalRead(MISO) == HIGH) {
        };

        // For Arduino                 
        char result =  SPI.transfer(strobe);    
        // For ATtiny85
        //char result =  SPI85.transfer(strobe);
        
        digitalWrite(SS,HIGH);
        delay(10);
        return result;
}


void init_CC2500()
{
  WriteReg(REG_IOCFG2,VAL_IOCFG2);
  WriteReg(REG_IOCFG1,VAL_IOCFG1);
  WriteReg(REG_IOCFG0,VAL_IOCFG0);

  WriteReg(REG_FIFOTHR,VAL_FIFOTHR);
  WriteReg(REG_SYNC1,VAL_SYNC1);
  WriteReg(REG_SYNC0,VAL_SYNC0);
  WriteReg(REG_PKTLEN,VAL_PKTLEN);
  WriteReg(REG_PKTCTRL1,VAL_PKTCTRL1);
  WriteReg(REG_PKTCTRL0,VAL_PKTCTRL0);
  WriteReg(REG_ADDR,VAL_ADDR);
  WriteReg(REG_CHANNR,VAL_CHANNR);
  WriteReg(REG_FSCTRL1,VAL_FSCTRL1);
  WriteReg(REG_FSCTRL0,VAL_FSCTRL0);
  WriteReg(REG_FREQ2,VAL_FREQ2);
  WriteReg(REG_FREQ1,VAL_FREQ1);
  WriteReg(REG_FREQ0,VAL_FREQ0);
  WriteReg(REG_MDMCFG4,VAL_MDMCFG4);
  WriteReg(REG_MDMCFG3,VAL_MDMCFG3);
  WriteReg(REG_MDMCFG2,VAL_MDMCFG2);
  WriteReg(REG_MDMCFG1,VAL_MDMCFG1);
  WriteReg(REG_MDMCFG0,VAL_MDMCFG0);
  WriteReg(REG_DEVIATN,VAL_DEVIATN);
  WriteReg(REG_MCSM2,VAL_MCSM2);
  WriteReg(REG_MCSM1,VAL_MCSM1);
  WriteReg(REG_MCSM0,VAL_MCSM0);
  WriteReg(REG_FOCCFG,VAL_FOCCFG);

  WriteReg(REG_BSCFG,VAL_BSCFG);
  WriteReg(REG_AGCCTRL2,VAL_AGCCTRL2);
  WriteReg(REG_AGCCTRL1,VAL_AGCCTRL1);
  WriteReg(REG_AGCCTRL0,VAL_AGCCTRL0);
  WriteReg(REG_WOREVT1,VAL_WOREVT1);
  WriteReg(REG_WOREVT0,VAL_WOREVT0);
  WriteReg(REG_WORCTRL,VAL_WORCTRL);
  WriteReg(REG_FREND1,VAL_FREND1);
  WriteReg(REG_FREND0,VAL_FREND0);
  WriteReg(REG_FSCAL3,VAL_FSCAL3);
  WriteReg(REG_FSCAL2,VAL_FSCAL2);
  WriteReg(REG_FSCAL1,VAL_FSCAL1);
  WriteReg(REG_FSCAL0,VAL_FSCAL0);
  WriteReg(REG_RCCTRL1,VAL_RCCTRL1);
  WriteReg(REG_RCCTRL0,VAL_RCCTRL0);
  WriteReg(REG_FSTEST,VAL_FSTEST);
  WriteReg(REG_PTEST,VAL_PTEST);
  WriteReg(REG_AGCTEST,VAL_AGCTEST);
  WriteReg(REG_TEST2,VAL_TEST2);
  WriteReg(REG_TEST1,VAL_TEST1);
  WriteReg(REG_TEST0,VAL_TEST0);
/*  
  WriteReg(REG_PARTNUM,VAL_PARTNUM);
  WriteReg(REG_VERSION,VAL_VERSION);
  WriteReg(REG_FREQEST,VAL_FREQEST);
  WriteReg(REG_LQI,VAL_LQI);
  WriteReg(REG_RSSI,VAL_RSSI);
  WriteReg(REG_MARCSTATE,VAL_MARCSTATE);
  WriteReg(REG_WORTIME1,VAL_WORTIME1);
  WriteReg(REG_WORTIME0,VAL_WORTIME0);
  WriteReg(REG_PKTSTATUS,VAL_PKTSTATUS);
  WriteReg(REG_VCO_VC_DAC,VAL_VCO_VC_DAC);
  WriteReg(REG_TXBYTES,VAL_TXBYTES);
  WriteReg(REG_RXBYTES,VAL_RXBYTES);
  WriteReg(REG_RCCTRL1_STATUS,VAL_RCCTRL1_STATUS);
  WriteReg(REG_RCCTRL0_STATUS,VAL_RCCTRL0_STATUS);
  */
}

void Read_Config_Regs(void)
{ 
   // For Arduino                 
   Serial.println(ReadReg(REG_IOCFG2),HEX);
   delay(10);
   Serial.println(ReadReg(REG_IOCFG1),HEX);
   delay(10);
   Serial.println(ReadReg(REG_IOCFG0),HEX);
   delay(10);
   
/* Serial.println(ReadReg(REG_FIFOTHR),HEX);
   delay(10);
  Serial.println(ReadReg(REG_SYNC1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_SYNC0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_PKTLEN),HEX);
   delay(10);
  Serial.println(ReadReg(REG_PKTCTRL1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_PKTCTRL0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_ADDR),HEX);
   delay(10);
  Serial.println(ReadReg(REG_CHANNR),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCTRL1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCTRL0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FREQ2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FREQ1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FREQ0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MDMCFG4),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MDMCFG3),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MDMCFG2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MDMCFG1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MDMCFG0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_DEVIATN),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MCSM2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MCSM1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_MCSM0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FOCCFG),HEX);
   delay(10);

  Serial.println(ReadReg(REG_BSCFG),HEX);
   delay(10);
  Serial.println(ReadReg(REG_AGCCTRL2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_AGCCTRL1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_AGCCTRL0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_WOREVT1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_WOREVT0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_WORCTRL),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FREND1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FREND0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCAL3),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCAL2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCAL1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSCAL0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_RCCTRL1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_RCCTRL0),HEX);
   delay(10);
  Serial.println(ReadReg(REG_FSTEST),HEX);
   delay(10);
  Serial.println(ReadReg(REG_PTEST),HEX);
   delay(10);
  Serial.println(ReadReg(REG_AGCTEST),HEX);
   delay(10);
  Serial.println(ReadReg(REG_TEST2),HEX);
   delay(10);
  Serial.println(ReadReg(REG_TEST1),HEX);
   delay(10);
  Serial.println(ReadReg(REG_TEST0),HEX);
   delay(10);
 /*
  Serial.println(ReadReg(REG_PARTNUM),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_VERSION),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_FREQEST),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_LQI),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_RSSI),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_MARCSTATE),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_WORTIME1),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_WORTIME0),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_PKTSTATUS),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_VCO_VC_DAC),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_TXBYTES),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_RXBYTES),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_RCCTRL1_STATUS),HEX);
   delay(1000);
  Serial.println(ReadReg(REG_RCCTRL0_STATUS),HEX);
   delay(1000);
*/  
}


