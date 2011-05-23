

configuration DiagnosisC
{
	provides 
	{
		interface Diagnosis;
	}
	/*uses 
	{
		//interface Send;
		interface LocalTime<TMilli>;
	}
	*/
}

implementation
{
	components DiagnosisP, new CollectionSenderC(AM_EVENT);
	
	components CollectionC as Collector;

	components HilTimerMilliC;
	Diagnosis = DiagnosisP.Diagnosis;
	DiagnosisP.LocalTime -> HilTimerMilliC;
	DiagnosisP.Send -> CollectionSenderC.Send;
	DiagnosisP.Intercept -> Collector.Intercept[AM_EVENT];
		
}
