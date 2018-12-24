/*****************************************************************************
*	Implemetation of the saliency detction method described in paper
*	"Exploit Surroundedness for Saliency Detection: A Boolean Map Approach",
*   Jianming Zhang, Stan Sclaroff, submitted to PAMI, 2014
*
*	Copyright (C) 2014 Jianming Zhang
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*	If you have problems about this software, please contact: jmzhang@bu.edu
*******************************************************************************/

#include <iostream>
#include <ctime>

#include "opencv2/opencv.hpp"
#include "BMS.h"
#include "fileGettor.h"

#define MAX_IMG_DIM 400

using namespace cv;
using namespace std;

void help() {
  cout << "Usage: \n"
       << "BMS <input_path> <output_path> <step_size> <dilation_width1> "
          "<dilation_width2> <blurring_std> <color_space> <whitening> "
          "<max_dim>\n"
       << "Press ENTER to continue ..." << endl;
  getchar();
}

void doWork(const string& in_path, const string& out_path, int sample_step,
            int dilation_width_1, int dilation_width_2, float blur_std,
            bool use_normalize, bool handle_border, int colorSpace,
            bool whitening, float max_dimension) {
  // TODO: FIXME hack to get working in the context of SMILER. part 1/3.
  // if (in_path.compare(out_path) == 0)
  //   cerr << "output path must be different from input path!" << endl;
  // FileGettor fg(in_path.c_str());
  // vector<string> file_list = fg.getFileList();

  vector<string> file_list;
  file_list.push_back(in_path);

  clock_t ttt;
  double avg_time = 0;
  //#pragma omp parallel for
  for (int i = 0; i < file_list.size(); i++) {
    /* get file name */
    string ext = getExtension(file_list[i]);
    if (!(ext.compare("jpg") == 0 || ext.compare("jpeg") == 0 ||
          ext.compare("JPG") == 0 || ext.compare("tif") == 0 ||
          ext.compare("png") == 0 || ext.compare("bmp") == 0))
      continue;
    // cout<<file_list[i]<<"...";

    /* Preprocessing */
    // TODO: FIXME hack part 2/3.
    Mat src = imread(file_list[i]);

    Mat src_small;
    float w = (float)src.cols, h = (float)src.rows;
    float maxD = max(w, h);
    if (max_dimension < 0)
      resize(src, src_small,
             Size((int)(MAX_IMG_DIM * w / maxD), (int)(MAX_IMG_DIM * h / maxD)),
             0.0, 0.0, INTER_AREA);  // standard: width: 600 pixel
    else
      resize(src, src_small, Size((int)(max_dimension * w / maxD),
                                  (int)(max_dimension * h / maxD)),
             0.0, 0.0, INTER_AREA);

    /* Computing saliency */
    ttt = clock();

    BMS bms(src_small, dilation_width_1, use_normalize, handle_border,
            colorSpace, whitening);
    bms.computeSaliency((double)sample_step);

    Mat result = bms.getSaliencyMap();

    /* Post-processing */

    if (dilation_width_2 > 0)
      dilate(result, result, Mat(), Point(-1, -1), dilation_width_2);
    if (blur_std > 0) {
      int blur_width = (int)MIN(floor(blur_std) * 4 + 1, 51);
      GaussianBlur(result, result, Size(blur_width, blur_width), blur_std,
                   blur_std);
    }

    ttt = clock() - ttt;
    float process_time = (float)ttt / CLOCKS_PER_SEC;
    avg_time += process_time;
    // cout<<"average_time: "<<avg_time/(i+1)<<endl;

    /* Save the saliency map*/
    resize(result, result, src.size());
    // TODO: FIXME SMILER hack part 3/3.
    // imwrite(out_path + "/" + rmExtension(file_list[i]) + ".png", result);
    imwrite(out_path, result);
  }
  // cout << "average_time: " << avg_time / file_list.size() << endl;
}

int main(int args, char** argv) {
  if (args < 9) {
    cout << "wrong number of input arguments." << endl;
    help();
    return 1;
  }

  /* initialize system parameters */
  string INPUT_PATH = argv[1];
  string OUTPUT_PATH = argv[2];
  int SAMPLE_STEP = atoi(argv[3]);  // 8: delta

  /*Note: we transform the kernel width to the equivalent iteration
  number for OpenCV's **dilate** and **erode** functions**/
  int DILATION_WIDTH_1 = (atoi(argv[4]) - 1) / 2;  // 3: omega_d1
  int DILATION_WIDTH_2 = (atoi(argv[5]) - 1) / 2;  // 11: omega_d2

  float BLUR_STD = (float)atof(argv[6]);  // 20: sigma
  bool NORMALIZE = 1 /*atoi(argv[7])*/;  // 1: whether to use L2-normalization
  bool HANDLE_BORDER =
      0 /*atoi(argv[8])*/;  // 0: to handle the images with artificial frames
  int COLORSPACE = atoi(argv[7]);  //
  bool WHITENING = atoi(argv[8]);

  float MAX_DIM = -1.0f;
  if (args > 9) MAX_DIM = (float)atof(argv[9]);

  doWork(INPUT_PATH, OUTPUT_PATH, SAMPLE_STEP, DILATION_WIDTH_1,
         DILATION_WIDTH_2, BLUR_STD, NORMALIZE, HANDLE_BORDER, COLORSPACE,
         WHITENING, MAX_DIM);

  return 0;
}
