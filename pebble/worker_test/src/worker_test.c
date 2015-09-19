/*
 * src/worker_test.c
 * Creates a Window and two TextLayers to display instructions and feedback 
 * from the background worker. 
 */

#include <pebble.h>

#define WORKER_TICKS 0

static Window *s_main_window;
static TextLayer *s_output_layer, *s_ticks_layer, *s_x_layer, *s_y_layer;

static void worker_message_handler(uint16_t type, AppWorkerMessage *data) {
  // Updated the UI with info from worker


  if (type == WORKER_TICKS) { 
    // Read ticks from worker's packet
    int x = data->data0;
    int y = data->data1;

    // Show to user in TextLayer
    static char s_buffer_x[32], s_buffer_y[32];

    snprintf(s_buffer_x, sizeof(s_buffer_x), "x: %d ", x);
    text_layer_set_text(s_x_layer, s_buffer_x);

    snprintf(s_buffer_y, sizeof(s_buffer_y), "y: %d ", y);
    text_layer_set_text(s_y_layer, s_buffer_y);

  }

}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  // Check to see if the worker is currently active
  bool running = app_worker_is_running();

  // Toggle running state
  AppWorkerResult result;
  if (running) {
    result = app_worker_kill();

    if (result == APP_WORKER_RESULT_SUCCESS) {
      text_layer_set_text(s_ticks_layer, "Worker stopped!");
    } else {
      text_layer_set_text(s_ticks_layer, "Error killing worker!");
    }
  } else {
    result = app_worker_launch();

    if (result == APP_WORKER_RESULT_SUCCESS) {
      text_layer_set_text(s_ticks_layer, "Worker launched!");
    } else {
      text_layer_set_text(s_ticks_layer, "Error launching worker!");
    }
  }

  APP_LOG(APP_LOG_LEVEL_INFO, "Result: %d", result);
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
}

static void make_layer(Layer* win_layer, TextLayer* layer, char* str){

  text_layer_set_background_color(layer, GColorClear);
  text_layer_set_text_alignment(layer, GTextAlignmentCenter);
  text_layer_set_text(layer, str);
  layer_add_child(win_layer, text_layer_get_layer(layer));
  text_layer_set_font(layer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));

}

static void main_window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect window_bounds = layer_get_bounds(window_layer);

  // Create UI
  s_output_layer = text_layer_create(GRect(0, 0, window_bounds.size.w, window_bounds.size.h));
  text_layer_set_text(s_output_layer, "Use SELECT to start/stop the background worker.");
  text_layer_set_text_alignment(s_output_layer, GTextAlignmentCenter);
  layer_add_child(window_layer, text_layer_get_layer(s_output_layer));

  s_ticks_layer = text_layer_create(GRect(30, 50, window_bounds.size.w, 30));
  text_layer_set_text(s_ticks_layer, "No data yet.");
  text_layer_set_text_alignment(s_ticks_layer, GTextAlignmentLeft);
  layer_add_child(window_layer, text_layer_get_layer(s_ticks_layer));

  // Create TextLayer for custom font
  s_x_layer = text_layer_create(GRect(0, 75, 144, 85));
  char* text = malloc(sizeof("Accelerometer Data"));
  strncpy(text, "Accelerometer Data", sizeof("Accelerometer Data"));
  make_layer(window_layer, s_x_layer, text);

  s_y_layer = text_layer_create(GRect(0, 105, 144, 85));
  char* text2 = malloc(sizeof("Accelerometer Data"));
  strncpy(text2, "Accelerometer Data", sizeof("Accelerometer Data"));
  make_layer(window_layer, s_y_layer, text2);



}



static void main_window_unload(Window *window) {
  // Destroy UI
  text_layer_destroy(s_output_layer);
  text_layer_destroy(s_ticks_layer);
}


static void init(void) {
  // Setup main Window
  s_main_window = window_create();
  window_set_click_config_provider(s_main_window, click_config_provider);
  window_set_window_handlers(s_main_window, (WindowHandlers) {
    .load = main_window_load,
    .unload = main_window_unload,
  });
  window_stack_push(s_main_window, true);

  // Subscribe to Worker messages
  app_worker_message_subscribe(worker_message_handler);
}

static void deinit(void) {
  // Destroy main Window
  window_destroy(s_main_window);

  // No more worker updates
  app_worker_message_unsubscribe();
}

int main(void) {
  init();
  app_event_loop();
  deinit();
}