#include <opencv2/opencv.hpp>
#include <iostream>
#include <chrono>

int main(int argc, char** argv) {
    // Check if filename parameter is provided
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <image_filename>" << std::endl;
        return -1;
    }

    // Load the image from the first parameter (filename)
    cv::Mat image = cv::imread(argv[1], cv::IMREAD_GRAYSCALE);
    if (image.empty()) {
        std::cerr << "Could not open or find the image!" << std::endl;
        return -1;
    }

    std::cout << "Image size : (" << image.size() << ")" << std::endl;

    // Start timing the execution
    auto start = std::chrono::high_resolution_clock::now();

    // Perform Canny edge detection
    cv::Mat edges;
    cv::Canny(image, edges, 100, 200);

    // End timing the execution
    auto end = std::chrono::high_resolution_clock::now();

    // Calculate the elapsed time
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << "Canny edge detection execution time: " 
              << duration.count() << " microseconds" << std::endl;

    // Display the result
    cv::imshow("Edges", edges);
    cv::waitKey(0);

    return 0;
}
