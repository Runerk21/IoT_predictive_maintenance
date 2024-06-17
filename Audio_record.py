import numpy as np
import sounddevice as sd
import datetime
import threading
import queue as QueueModule

def record_audio(duration, samplerate, channels, data_queue):
    # Record audio
    recording = sd.rec(int(duration * samplerate), samplerate=samplerate, channels=channels, dtype='float32')
    sd.wait()  # Wait until recording is finished
    data_queue.put(recording) # Put data into queue


def save_segment(data_queue, segment_start_time, segment_duration_seconds):
    # Save segment data to file or any other storage method
    segment_filename = fr"D:\Data\segment_{segment_start_time.strftime('%Y%m%d_%H%M%S')}"
    # Get data from the queue
    recorded_segment = data_queue.get()
    # Add time values to array
    time_values = np.linspace(0, segment_duration_seconds, len(recorded_segment))
    data = np.column_stack((time_values, recorded_segment))
    # Create timestamps
    timestamps = [(segment_start_time + datetime.timedelta(seconds=time_values[i])).strftime('%Y-%m-%d %H:%M:%S') for i in range(len(recorded_segment))]
    # Add timestamp column to the data
    data_with_timestamp = np.column_stack((timestamps, data))
    np.savez_compressed(segment_filename, a=data_with_timestamp) # save compressed
    # np.savetxt(segment_filename, data_with_timestamp, delimiter=",", fmt="%s", header="Timestamp,Time (s),Amplitude", comments="") # save uncompressed

def main():
    segment_duration_seconds = 5
    samplerate = 44100
    channels = 1
    segments = 3

    # Create a queue for communication between threads
    data_queue = QueueModule.Queue(maxsize=0)

    for i in range(segments):
        # Get timestamp at the start of recording
        segment_start_time = datetime.datetime.now()
        # Start the recording thread
        recording_thread = threading.Thread(target=record_audio, args=(segment_duration_seconds, samplerate, channels, data_queue))
        recording_thread.start()
        # Wait for recording to stop
        recording_thread.join()
        # Start saving thread
        saving_thread = threading.Thread(target=save_segment, args=(data_queue, segment_start_time, segment_duration_seconds))
        saving_thread.start()

if __name__ == "__main__":
    main()
