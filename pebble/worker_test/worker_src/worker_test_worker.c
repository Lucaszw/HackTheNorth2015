/*
 * worker_src/worker_test_worker.c
 * Launched and killed from the foreground app. Counts seconds passing 
 * and reports them using AppWorkerMessages.
 */

#include <pebble_worker.h>

#define WORKER_DATA 0


static void data_handler(AccelData *data, uint32_t num_samples) {
  
  static char s_buffer[128];

  // Compose string of all data
  snprintf(s_buffer, sizeof(s_buffer), 
    "N X,Y,Z\n0 %d,%d,%d\n1 %d,%d,%d\n2 %d,%d,%d", 
    data[0].x, data[0].y, data[0].z, 
    data[1].x, data[1].y, data[1].z, 
    data[2].x, data[2].y, data[2].z
  );

  // Construct a data packet
  AppWorkerMessage msg_data = {
    .data0 = data[0].x,
    .data1 = data[0].y,
    .data2 = data[0].z,
  };

  // Send the data to the foreground app
  app_worker_send_message(WORKER_DATA, &msg_data);
}

static void worker_init() {

    int num_samples = 3;
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