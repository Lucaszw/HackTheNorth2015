/*
 * worker_src/worker_test_worker.c
 * Launched and killed from the foreground app. Counts seconds passing 
 * and reports them using AppWorkerMessages.
 */

#include <pebble_worker.h>


#define ACCEL_DATA 0

static void data_handler(AccelData *data, uint32_t num_samples) {
  
  static uint8_t s_buffer[128];

  // Compose string of all data
  // snprintf(s_buffer, sizeof(s_buffer), 
  //   "N X,Y,Z\n0 %d,%d,%d\n1 %d,%d,%d\n2 %d,%d,%d", 
  //   data[0].x, data[0].y, data[0].z, 
  // );

  // Construct a data packet
  AppWorkerMessage xyz_data = {
    .data0 = data[0].x,
    .data1 = data[0].y, 
    .data2 = data[0].z
  };

  // AppWorkerMessage y_data = {
  //   .data0 = data[0].y,
  //   .data1 = data[1].y,
  //   .data2 = data[2].y,
  // };

  // AppWorkerMessage z_data = {
  //   .data0 = data[0].z,
  //   .data1 = data[1].z,
  //   .data2 = data[2].z,
  // };

  // Send the data to the foreground app
  app_worker_send_message(ACCEL_DATA, &xyz_data);
}

static void worker_init() {

    uint8_t num_samples = 1;
    accel_data_service_subscribe(num_samples, data_handler);
    // Choose update rate
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);

}

static void worker_deinit() {
    accel_data_service_unsubscribe();
}

int main(void) {
  worker_init();
  worker_event_loop();
  worker_deinit();
}