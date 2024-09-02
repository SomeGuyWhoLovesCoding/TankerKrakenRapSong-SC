package;

// BE CAREFUL, BECAUSE THESE THINGS MIGHT MAKE YOUR COMPUTER A BIT UNSTABLE

// Window Border color code From: https://stackoverflow.com/questions/39261826/change-the-color-of-the-title-bar-caption-of-a-win32-application
// Window Transparency Code From: https://stackoverflow.com/questions/61246102/win32-prevent-being-transparent-the-borders-of-the-window
// Transparent Window Code by Duskiewhy :skull:

@:cppFileCode('#include <iostream>\n#include <iostream>\n#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class FlxWindow
{
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE));
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(13, 13, 13), 1, LWA_COLORKEY);
        }
    ')

	static public function getWindowsTransparent(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
        HWND hWnd = GetActiveWindow();

        //res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_TRANSPARENT);
        res = SetWindowLongPtr(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, WS_EX_TRANSPARENT) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(13, 13, 13), 1, LWA_COLORKEY);
        }
    ')

	static public function getWindowsbackward(res:Int = 0)
	{
		return res;
	}
    
    @:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(0, 0, 0), 1, LWA_ALPHA);
        }
    ')

	static public function setWindowAlpha(res:Float = 0)
	{
		return res;
	}

    @:functionCode('
        // ChatGPT Code moment
        /*HWND hwnd = GetForegroundWindow(); // get handle to the foreground window
        if (hwnd != NULL)
        {
            // enable DWM composition
            DWMENABLECOMPOSITION dwmEnableComposition = { DWM_EC_DISABLECOMPOSITION };
            DwmEnableComposition(DWM_EC_DISABLECOMPOSITION);

            // set the window caption color to red
            DWORD redColor = 0xFF0000;
            DWM_COLORIZATION_PARAMS colorizationParams = { 0 };
            colorizationParams.ColorizationColor = redColor;
            DwmSetWindowAttribute(hwnd, DWMWA_CAPTION_COLOR, &colorizationParams, sizeof(colorizationParams));

            // disable DWM composition
            DwmEnableComposition(DWM_EC_ENABLECOMPOSITION);
        }

        */HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_WINDOWEDGE);
        const MARGINS shadow_on = { 0, 1, 0, 1 };
        if (res)
        {
            DwmExtendFrameIntoClientArea(hWnd, &shadow_on);
        }
    ')
    
	static public function tankerKrakenWindow(res:Int = 0)
	{
		return res;
	}
}