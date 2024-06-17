Get audio data in specific segments:
1. run Audio_record.py on the raspberry pi in the IoT-box. It will save multiple compressed files specified in the code. This is to mitigate memory and storage usage.
2. run Decompress_NPZ_all.py on the audio files with machining operation inside.
3. run Cut_segments.m with start/stop-timestamps
 

IMU with database storage: 
1. run ESP_Box_IMU.ino on the ESP (node-red code on the IoT Box is necessary for database storage)
2. run IMU_DataExtraction.m with start/stop-timestamps
   

Run InterpretData.m with adjusted thresholds to interpret the machining operation
