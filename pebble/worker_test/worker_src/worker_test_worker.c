/*
 * worker_src/worker_test_worker.c
 * Launched and killed from the foreground app. Counts seconds passing 
 * and reports them using AppWorkerMessages.
 */

#include <pebble_worker.h>


#define ACCEL_DATA 0

DataLoggingSessionRef accel_data_logger;

static void data_handler(AccelData *data, uint32_t num_samples) {
  
  data_logging_log(accel_data_logger, data, num_samples);

  // Construct a data packet
  AppWorkerMessage xyz_data = {
    .data0 = data[0].x,
    .data1 = data[0].y, 
    .data2 = data[0].z
  };

  // Send the data to the foreground app
  app_worker_send_message(ACCEL_DATA, &xyz_data);
}

static void worker_init() {

    uint8_t num_samples = 1;
    accel_data_service_subscribe(num_samples, data_handler);
    // Choose update rate
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
    accel_data_logger = data_logging_create(1, DATA_LOGGING_BYTE_ARRAY, sizeof(AccelData), true); 

}

static void worker_deinit() {
    data_logging_finish(accel_data_logger);
    accel_data_service_unsubscribe();
}

int main(void) {
  worker_init();
  worker_event_loop();
  worker_deinit();
}