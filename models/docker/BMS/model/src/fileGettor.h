#ifndef FILE_GETTOR
#define FILE_GETTOR

#include <vector>
#include <string>
#include <cstdio>

#include "OS_specific.h"
using namespace std;

class FileGettor
{
public:
	FileGettor(const char* directory):_count(0)
	{
		char tmpDirSpec[100+1];
		sprintf (tmpDirSpec, "%s*", directory);

#if OS_type==2 //for windows
		WIN32_FIND_DATAA f;
		HANDLE h = FindFirstFileA(tmpDirSpec , &f); // read .
		if(h != INVALID_HANDLE_VALUE)
		{
			FindNextFileA(h, &f);	//read ..
			while(FindNextFileA(h, &f))
				_name_list.push_back(f.cFileName);
		}
		FindClose(h);
#endif

#if OS_type==1 //for linux
		DIR *dp;
		struct dirent *dirp;
		if((dp = opendir(directory)) == NULL) {
			cout << "Error opening " << directory << endl;
		}

		while ((dirp = readdir(dp)) != NULL) {
			string filename(dirp->d_name);
			_name_list.push_back(filename);
		}
		//std::sort(_m_fileNames.begin(),_m_fileNames.end());
		closedir(dp);
#endif
	}
	inline std::vector<std::string>& getFileList(){return _name_list;}
	inline bool getNextName(std::string& filename)
	{
		if (_count<_name_list.size())
		{
			filename=_name_list[_count++];
			return true;
		}
		return false;
	}
private:
	std::vector<std::string> _name_list;
	int _count;
};

inline string getExtension(const string filename)
{
	size_t p=filename.find_last_of(".");
	return filename.substr(p+1,filename.size()-p-1);
}
inline string rmExtension(const string oni_file)
{
	size_t p=oni_file.find_last_of(".");
	return oni_file.substr(0,p);
}
inline string getFileName(const string filepath)
{
	size_t p=filepath.find_last_of("/");
	return filepath.substr(p+1,filepath.size()-p-1);
}



#endif
