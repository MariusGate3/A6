#include "lib.h"

int heap[100000];
int size = 0;

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void heapify_up(int index) {
    while (index > 0) {
        int parent = (index - 1) / 2;
        if (heap[parent] <= heap[index]) {
          break; 
        }
        swap(&heap[parent], &heap[index]);
        index = parent;
    }
}

void heapify_down(int index) {
    while (2 * index + 1 < size) {
        int left = 2 * index + 1;
        int right = 2 * index + 2;
        int min = left;

        if (right < size && heap[right] < heap[left]) {
            min = right;
        }

        if (heap[index] <= heap[min]) {
          break;
        }
        swap(&heap[index], &heap[min]);
        index = min;
    }
}

void add_number(int priority) {
    if (size >= 100000) {
        print_string("Priority queue overflow\n");
        terminate(-1);
    }
    heap[size] = priority;
    heapify_up(size);
    size++;
}

int take_num() {
    if (size == 0) {
        print_string("Priority queue is empty\n");
        terminate(-1);
    }
    int num = heap[0];
    heap[0] = heap[--size];
    heapify_down(0);
    return num;
}

// Take numbers and fill the buffer
int take_numbers(int* buffer, int max_nums) {
    int count = 0;
    while (count < max_nums && size > 0) {
        buffer[count++] = take_num();
    }
    return count;
}

void main(int argc, char* argv[]) {
    if (argc != 3) {
        print_string("Use: radix_new input-file output-file\n");
        terminate(-1);
    }

    int in_file = open_file(argv[1], "r");
    if (in_file < 0) {
        print_string("Could not open input file\n");
        terminate(-1);
    }
    int out_file = open_file(argv[2], "w");
    if (out_file < 0) {
        print_string("Could not open output file\n");
        terminate(-1);
    }

    int numbers[1000];
    int out_numbers[1000];

    while (1) {
        int read = read_int_buffer(in_file, numbers, 1000);
        if (read <= 0) break;

        for (int n = 0; n < read; ++n) {
            if (numbers[n] < 0) {
                int limit = -numbers[n];
                while (limit > 0) {
                    int take_max = limit < 1000 ? limit : 1000;
                    int taken = take_numbers(out_numbers, take_max);
                    write_int_buffer(out_file, out_numbers, taken);
                    limit -= taken;
                }
            } else {
                add_number(numbers[n]);
            }
        }
    }

    close_file(in_file);
    close_file(out_file);
}