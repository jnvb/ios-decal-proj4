// SSC_01_14_12_51.cpp
//
#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <winsock2.h>
#include <atlimage.h>
#include <atltime.h>
#include <atlstr.h> 
#include <windows.h>
#include <winbase.h>
#include <process.h>
#include <tlhelp32.h> 

#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "Advapi32.lib")

#define BUF_SIZE 1024

void dll_load(WSADATA *wsaData);
void conn_init(SOCKET *serv_sock, SOCKADDR_IN *serv_addr, int port);
void accept_client(SOCKET *clnt_sock, SOCKET *serv_sock, SOCKADDR_IN *clnt_addr, int *size);
void conn_finish(SOCKET *clnt_sock);
void ErrorHandling(char *message);
void SendKey(HWND hWndTargetWindow, BYTE virtualKey);
DWORD ListProcess(CString aa);
BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam);

void screenShot()
{
	HWND hWndTarget = FindWindow(NULL, L"FIFA Online 2 Korea");

	if (SetForegroundWindow(hWndTarget))
		SendKey(hWndTarget, VK_SNAPSHOT);
}

int _tmain(int argc, _TCHAR* argv[])
{
	WSADATA wsaData;
	SOCKET hServSock, hClntSock;
	SOCKADDR_IN serv_addr, clnt_addr;
	FILE *fp, *f_size;
	char message[BUF_SIZE];
	int clntAddrSize, len;
	int nx = 0, ny = 0;
	int ret;
	char data[BUF_SIZE];
	HWND hWnd_desktop = GetDesktopWindow();
	HWND hWnd_console = GetConsoleWindow();
	CImage capImage;
	HDC hdc = NULL;
	nx = GetSystemMetrics(SM_CXSCREEN);
	ny = GetSystemMetrics(SM_CYSCREEN);
	if(!hWnd_desktop) return 0;
	if(!hWnd_console) return 0;
	if(!capImage.Create(nx, ny, 32)) return 0;
	DWORD dwError;
	CTime t = CTime::GetCurrentTime();
	char szPath[] = "C:\\SCC";
	char szPath2[] = "C:\\SCC\\ProcessLog";
	//ShowWindow(hWnd_console, SW_HIDE);
	char currentDirectory[BUF_SIZE];
	GetCurrentDirectoryA(BUF_SIZE, currentDirectory);
	char serviceAdd[BUF_SIZE] = "\"";

	dll_load(&wsaData);
	memset(&serv_addr, 0, sizeof(serv_addr));
	conn_init(&hServSock, &serv_addr, 1234);

	if(bind(hServSock, (SOCKADDR*)&serv_addr, sizeof(serv_addr)) == SOCKET_ERROR)
		ErrorHandling("bind() Error");

	if(listen(hServSock, 5) == SOCKET_ERROR)
		ErrorHandling("listen() Error");

	clntAddrSize = sizeof(clnt_addr);

	while(1)
	{
		accept_client(&hClntSock, &hServSock, &clnt_addr, &clntAddrSize);
		
		memset(data, 0, sizeof data);
		ret = recv(hClntSock, data, 1024, 0);

		if(ret = 0 || WSAGetLastError() ==WSAETIMEDOUT) continue;
		
		if(ret == SOCKET_ERROR)
		{
			printf("WSAGETLASTERROR\n", WSAGetLastError());
			WSACleanup(); return 0;
		}
//hello	
		if(strcmp(data, "hello") == 0)
		{
			//printf("hello\n");
			if(shutdown(hClntSock, SD_SEND) == SOCKET_ERROR)
				ErrorHandling("shutdown() Error");
		}
//Shutdown
		if(strcmp(data, "shutdown") == 0)
		{
			//printf("shutdown\n");
			system("shutdown -s -t 1");
		}
//ShutdownTest
		if(strcmp(data, "shutdownTest") == 0)
		{
			//printf("shutdown\n");
			system("shutdown -s -t 100");
		}
//Process_Terminate
		if(data[16] == '|')
		{
			char tmp[100] = {0x0,};
			int cnt = 0;

			for(int i = 17; i < strlen(data); i++)
			{
				tmp[cnt] = data[i];
				cnt++;
			}

			int pid = atoi(tmp);
			char command[1024];

			sprintf(command, "taskkill /pid %d", pid);
			system(command);
		}


//SendMessage
		if(data[11] == '|')
		{
			char tmp[100] = {0x0, };
			int cnt = 0;

			for(int i = 12; i < strlen(data); i++)
			{
				tmp[cnt] = data[i];
				cnt++;
			}

			MessageBoxA(0, tmp, "Sent from Iphone", MB_OK);
		}
//Process_Get
		if(strcmp(data, "getProcess") == 0)
		{
			if (!CreateDirectoryA(szPath2, NULL))
			{
				dwError = GetLastError();
				switch (dwError)
				{
				case ERROR_ALREADY_EXISTS: break;
				default: CreateDirectoryA(szPath, NULL); break;
				}
			}
			EnumWindows(EnumWindowsProc, NULL);
			memset(message, 0, 1024);

			CTime t = CTime::GetCurrentTime();
			char processLog_file[BUF_SIZE];
			char *processLog_file_temp = "abcd";
			char test[BUF_SIZE] = "C:\\SCC\\ProcessLog\\test.txt";
			sprintf(processLog_file, "C:\\SCC\\ProcessLog\\%d%02d%02d%02d%02d%02d.txt", t.GetYear(), t.GetMonth(), t.GetDay(), t.GetHour(), t.GetMinute(), t.GetSecond());
			processLog_file_temp = processLog_file;

			//printf("processLog_file = %s \n", processLog_file);
			//printf("processLog_file_temp = %s \n", processLog_file_temp);

			f_size = fopen(processLog_file_temp, "r");
			if(f_size)
			{
				//printf("f_size\n");
				int size;
				fseek(f_size, 0, SEEK_END);
				size = ftell(f_size);
				char file_size[BUF_SIZE];
				itoa(size, file_size, 10);
				send(hClntSock, file_size, BUF_SIZE, 0);

				fp = fopen(processLog_file_temp, "rb");
				if(fp)
				{
					//printf("Sending\n");
					while(1)
					{
						len = fread(message, sizeof(char), BUF_SIZE, fp);
						send(hClntSock, message, len, 0);

						if(feof(fp)) 
						{
							Sleep(1500);
							send(hClntSock, "0", 2, 0);
							//printf("End Of File\n");
							break;
						}
					}
					//printf("Done ...\n");
					fclose(fp);
				}
				else{printf("No\n");}
			}
			else{printf("N0\n");}

			if(shutdown(hClntSock, SD_SEND) == SOCKET_ERROR)
				ErrorHandling("shutdown() Error");
		}
//ScreenShot
		if(strcmp(data, "getScreenshot") == 0)
		{
			//printf("screenshot\n");
			if (!CreateDirectoryA(szPath, NULL))
			{
				dwError = GetLastError();
				switch (dwError)
				{
				case ERROR_ALREADY_EXISTS: break;
				default: CreateDirectoryA(szPath, NULL); break;
				}
			}
			memset(message, 0, 1024);
			hdc = capImage.GetDC();
			BitBlt(hdc, 0, 0, nx, ny, GetWindowDC(hWnd_desktop), 0, 0, SRCCOPY);
			capImage.Save(_T("C:\\SCC\\temp.jpg"), Gdiplus::ImageFormatJPEG);
			capImage.ReleaseDC();

			f_size = fopen("C:\\SCC\\temp.jpg", "r");
			int size;
			fseek(f_size, 0, SEEK_END);
			size = ftell(f_size);
			char file_size[BUF_SIZE];
			itoa(size, file_size, 10);
			//char *size = file_size;
			send(hClntSock, file_size, BUF_SIZE, 0);

			fp = fopen("C:\\SCC\\temp.jpg", "rb");
			if(fp == NULL)
			{
				ErrorHandling("File Open Error!");
				continue;
			}
			else
			{
				//printf("Sending ...\n");
				while(1)
				{
					len = fread(message, sizeof(char), BUF_SIZE, fp);
					send(hClntSock, message, len, 0);

					if(feof(fp)) 
					{
						Sleep(1500);
						send(hClntSock, "0", 2, 0);
						//printf("End Of File\n");
						break;
					}
				}
				//printf("Done ...\n");
			}
			fclose(fp);
			if(shutdown(hClntSock, SD_SEND) == SOCKET_ERROR)
				ErrorHandling("shutdown() Error");
		}
		puts(data);
	}

	if(shutdown(hClntSock, SD_SEND) == SOCKET_ERROR)
		ErrorHandling("shutdown() Error");

	len = (hClntSock, message, BUF_SIZE-1, 0);
	message[len] = 0;
	fputs(message, stdout);

	conn_finish(&hClntSock);
	
    return 0;
}

void dll_load(WSADATA *wsaData)
{
	if(WSAStartup(MAKEWORD(2, 2), wsaData) != 0)
		ErrorHandling("WSAStartup() Error");
}

void conn_init(SOCKET *serv_sock, SOCKADDR_IN *serv_addr, int port)
{
	*serv_sock = socket(PF_INET, SOCK_STREAM, 0);
	if(*serv_sock == INVALID_SOCKET)
		ErrorHandling("socket() Error!");
	
	serv_addr->sin_family = AF_INET;
	serv_addr->sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr->sin_port = htons(port);
}

void accept_client(SOCKET *clnt_sock, SOCKET *serv_sock, SOCKADDR_IN *clnt_addr, int *size)
{
	*clnt_sock = accept(*serv_sock, (SOCKADDR*)clnt_addr, size);
	if(*clnt_sock == INVALID_SOCKET)
		ErrorHandling("accepth() Error!!");
}

void conn_finish(SOCKET *clnt_sock)
{
	closesocket(*clnt_sock);
	WSACleanup();
}

void ErrorHandling(char *message)
{
	fputs(message, stdout);
	fputc('\n', stderr);
	exit(1);
}

void SendKey(HWND hWndTargetWindow, BYTE virtualKey)
{
	Sleep(100);
	keybd_event(virtualKey, 0, 0, 0);
	keybd_event(virtualKey, 0, KEYEVENTF_KEYUP, 0);
	Sleep(100);
}

DWORD ListProcess(CString ProcessName)
{
	PROCESSENTRY32 pe32={0}; 
	pe32.dwSize=sizeof(PROCESSENTRY32); 
	HANDLE hSnapshot=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); 
	if(hSnapshot==INVALID_HANDLE_VALUE) 
	{ 
		return NULL; 
	} 
	if(!::Process32First(hSnapshot, &pe32)) 
	{ 
		CloseHandle(hSnapshot); 
		return NULL; 
	} 
	DWORD CurrentPID=GetCurrentProcessId(); 
	do 
	{ 
		CString sProcessName=pe32.szExeFile; 
		if(sProcessName==ProcessName && CurrentPID!=pe32.th32ProcessID) 
		{ 
			CloseHandle(hSnapshot); 
			return pe32.th32ProcessID; 
		} 
	} 
	while(::Process32Next(hSnapshot, &pe32));
	CloseHandle(hSnapshot); 
	return NULL; 
}

BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam)
{
	CTime t = CTime::GetCurrentTime();
	char caption[BUF_SIZE];
	memset(caption, 0, sizeof(caption));
	int n = 0;
	DWORD pid = NULL;
	
	PROCESSENTRY32 pEntry;
	pEntry.dwSize = sizeof(pEntry);
	
	DWORD exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
	BOOL isVisible = IsWindowVisible(hwnd);
	BOOL isToolWindow = (exStyle & WS_EX_TOOLWINDOW);
	BOOL isAppWindow = (exStyle & WS_EX_APPWINDOW);
	BOOL isOwned = GetWindow(hwnd, GW_OWNER) ? TRUE : FALSE;
	
	if(!(isVisible && (isAppWindow || (!isToolWindow && !isOwned))))
		return TRUE;
	
	GetWindowTextA(hwnd,caption,1024);
	GetWindowThreadProcessId(hwnd, &pid);
	
	HANDLE hSnapShot = CreateToolhelp32Snapshot(TH32CS_SNAPALL, pid);

	Process32First (hSnapShot, &pEntry);
	
	HANDLE hProcess = ::OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
	
	while(!(pid == pEntry.th32ProcessID) && IsWindowVisible(hwnd))
	{
		BOOL hRes = Process32Next(hSnapShot, &pEntry);
		
        if(hRes == FALSE)
			break;
		hProcess = ::OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
	}
	
	char processLog_file[1024];
	FILE *fp;
	char *cap;
	cap = "abcd";
	cap = caption;
	sprintf(processLog_file, "C:\\SCC\\ProcessLog\\%d%02d%02d%02d%02d%02d.txt", t.GetYear(), t.GetMonth(), t.GetDay(), t.GetHour(), t.GetMinute(), t.GetSecond());
	fp = fopen(processLog_file, "a");
	if(fp)
		fprintf(fp,  "%6d - %s\n\n", pid, caption);

	else{}
	fclose(fp);
	
	return TRUE;
}