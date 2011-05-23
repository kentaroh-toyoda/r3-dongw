#include "Diagnosis.h"


interface Diagnosis
{
      command error_t insertEvent(nx_uint8_t eventType); 
      command error_t sendEventReport();
}
