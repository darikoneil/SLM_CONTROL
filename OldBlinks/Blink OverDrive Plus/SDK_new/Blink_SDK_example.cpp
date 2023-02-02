// Blink_SDK_example.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"  // Does nothing but #include targetver.h.

#include "Blink_SDK.h"  // Relative path to SDK header.
#include "ImageGen.h"
#include "math.h"
#include <Windows.h>


// ------------------------- Blink_SDK_example --------------------------------
// Simple example using the Blink_SDK DLL to send a sequence of phase targets
// to a single SLM.
// The code is written with human readability as the main goal.
// The Visual Studio 2013 sample project settings assume that Blink_SDK.lib is
// in relative path ../Blink_SDK/x64/Release.
// To run the example, ensure that Blink_SDK.dll is in the same directory as
// the Blink_SDK_example.exe.
// ----------------------------------------------------------------------------
int main()
{
  int board_number;
  // Construct a Blink_SDK instance with Overdrive capability.
  unsigned int bits_per_pixel = 12U;
  bool         is_nematic_type = true;
  bool         RAM_write_enable = true;
  bool         use_GPU_if_available = true;

  unsigned int n_boards_found = 0U;
  bool         constructed_okay = true;

  Blink_SDK sdk(bits_per_pixel, &n_boards_found,
    &constructed_okay, is_nematic_type, RAM_write_enable,
    use_GPU_if_available, 10U, 0);


  // Check that everything started up successfully.
  bool okay = constructed_okay;

  if (okay)
  {
    board_number = 1;
    //you should replace this with your custom LUT file
	char* lut_file = "C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\linear.LUT";
	sdk.Load_LUT_file(board_number, lut_file);

	int height = sdk.Get_image_height(board_number);
	int width = sdk.Get_image_width(board_number);
	// Create two vectors to hold values for two SLM images with opposite ramps.
	unsigned char* ImageOne = new unsigned char[width*height];
	unsigned char* ImageTwo = new unsigned char[width*height];
	// Generate phase gradients
	int VortexCharge = 5;
	Generate_LG(ImageOne, width, height, VortexCharge, width / 2.0, height / 2.0, false);
	VortexCharge = 3;
	Generate_LG(ImageTwo, width, height, VortexCharge, width / 2.0, height / 2.0, false);

	bool ExternalTrigger = false;
	bool OutputPulse = false;
	for (int i = 0; i < 5; i++)
	{
		//write image returns on DMA complete, ImageWriteComplete returns when the hardware
		//image buffer is ready to receive the next image. Breaking this into two functions is 
		//useful for external triggers. It is safe to apply a trigger when Write_image is complete
		//and it is safe to write a new image when ImageWriteComplete returns
		sdk.Write_image(board_number, ImageOne, width*height, ExternalTrigger, OutputPulse, 5000);
		sdk.ImageWriteComplete(board_number, 5000);
		Sleep(500);

		sdk.Write_image(board_number, ImageTwo, width*height, ExternalTrigger, OutputPulse, 5000);
		sdk.ImageWriteComplete(board_number, 5000);
		Sleep(500);
	}

	delete[]ImageOne;
	delete[]ImageTwo;

	sdk.SLM_power(false);
  }

  return (okay) ? EXIT_SUCCESS : EXIT_FAILURE;
}