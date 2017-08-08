/*
    toplevel.h is part of Appudo

    Copyright (C) 2015-2016
        48c43cf3fa27f38651415841249beb404bae737b543781675489887c65abc8b7 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

#include <netinet/in.h>
void printSub();
int CopyFrameData(void* wsinfo, unsigned char* target, long sizeLeft);
int CopyFrom(int eventFd, void* pid_source_buffer, void* target_buffer, unsigned int size, int target_pid);

// general funcs
void* getSwiftRunData();
char* getRunData();

// for pages only
void* __getSwiftRunData(char* base);
char* __getRunData(char* base);
char* __getStackBase();

void print_str(const char * ptr);
void debugPtr(const char * ptr);
void print_debug(const char * ptr);

void MenuItem_get(void* async, long pageId, long shift, int height);
int MenuItem_getNext(char* inst, void* tmp);

WebSocket_WriteFileAsText(void* holder, const unsigned int* target, unsigned int num_targets, int broadcast);
WebSocket_WriteFileAsBytes(void* holder, const unsigned int* target, unsigned int num_targets, int broadcast);
WebSocket_WriteText(void* holder, const unsigned int* target, unsigned int num_targets, int broadcast);
WebSocket_WriteBytes(void* holder, const unsigned int* target, unsigned int num_targets, int broadcast);
WebSocket_SendText(void* holder, int inFd, long size, const unsigned int* target, unsigned int num_targets, int broadcast);
WebSocket_SendBytes(void* holder, int inFd, long size, const unsigned int* target, unsigned int num_targets, int broadcast);

void Async_Init(void* async, int no_watch);
void Async_Reset(void* async, int ready);
int Async_isReady(const char* async);
int Async_Cancel(const char* async);
void Async_PushReady(const char* async);
const void* Async_getAsPtr(const char* async);
long Async_getAsInt(const char* async);
long Async_updateAsInt(const char* async, long newValue);
void Async_setPtr(const char* async, const void* ptr);
void Async_setInt(const char* async, long v);
char *Async_AddStructPad(void* async, long size, long align);
void Async_DelStructPad(char * pad);
void* Async_WaitAny();
void Async_WaitAll();
void Async_DoLater();
int Async_CallLater(void* value);
int AsyncObj_CallLaterAsync(void* async, void* value);

long Page_GetRoot();
long Page_GetCurrent();
long Page_GetTarget();
void Page_GetDomain(void* ret);
long Page_GetRequestType();
int Page_GetLang(int idx);
void Page_SetLang(int idx, int value);
int Page_GetAddr(struct sockaddr* addr);

unsigned int Page_GetSkinId();
void Page_SetSkinId(unsigned int id);
unsigned int Page_GetDoCache();
void Page_SetDoCache(unsigned int id);
void Page_GetPath(void* data);
void Page_GetAgent(void* data);
long Page_LastModified();
long Page_CountSubPath();

long Page_GetStatus();
void Page_SetStatus(long s);
long Page_GetError();
void Page_SetError(long s);

void Link_toPage(void* async, long pageId);
void Link_toView(void* async, long viewId, long idx);

void Account_Add(void* async, const char* name, const char* mail, const char* password, int master);
void Account_Get(void* async, const char* name);
void Account_DelByName(void* async, const char* name);
void Account_DelById(void* async, long accountId);
long Account_Current();
void Account_GetById(void* async, long accountId);
void Account_SetActive(void* async, long id, int value);
void Account_AddDomain(void* async, long id, const char* host);
void Account_DelDomain(void* async, long id, const char* host);
void Account_Info(void* async, long accountId);
void Account_PackageAccount(void* async, long accountId, int keepPasswords, int fileFd);
void Account_PackageDeploy(void* async, long accountId, int fileFd, const char* prefix);

void FileItem_Open(void* async, void* parent, const char* path, int flags, int mode);
void FileItem_OpenAt(void* async, const char* cbase, const char* cpath, void* parent, int flags, int mode);
void FileItem_CreateDir(void* async, const char* cbase, const char* cpath, void* parent, int flags, int mode);
void FileItem_Rename(void* async, const char* cbase, const char* cpath, const char* cnewbase, int flags);
void FileItem_Copy(void* async, const char* cbase, const char* cpath, const char* cnewbase);
void FileItem_Remove(void* async, const char* cbase, const char* cpath, int flags);
void FileItem_Access(void* async, const char *cbase, const char* cpath, int mode);
void FileItem_ReadAsText(void* async, void* info, long size, long offset);
void FileItem_ReadAsArray(void* async, void* info, long size, long offset);
void FileItem_Send(void* async, void* info, int outFd, long offset, long size);
void FileItem_CreateList(void* async, const void* parent, const void* cpath, int sorter, int chunkSize, const void* dir);
void FileItem_DestroyList(const void* dir);
void FileItem_GetFullPath(void* result, void* current);
void FileItem_CloseFile(int fileFd);
int FileItem_DupFile(int fileFd);
void FileItem_Write(void* async, void* info, const void* source, long size, long offset);
void FileItem_Append(void* async, void* info, const void* source, long size);
void FileItem_TruncateOpen(void* async, int fileFd, long size);
void FileItem_Truncate(void* async, const char* cbase, long size);
void FileItem_Seek(void* swiftAsync, int fileFd, long offset, int flag);
void FileItem_Link(void* swiftAsync, const char* cbase, const char* cpath, const char* cnewbase, int hard);
void FileItem_LinkOpen(void* swiftAsync, int fileFd, const char* cpath, const char* cnewbase, int hard);
void FileItem_CHMOD(void* async, const char* cbase, int mode, int flags);
void FileItem_CHOWN(void* async, const char* cbase, int uid, int group, int flags);
void FileItem_GetInfo(void* async, const char* cbase);
void FileItem_GetInfoOpen(void* async, int fileFd);
void FileItem_CreateDev(void* swiftAsync, long treeId, const char* csuffix, int mode);

long FileItem_PREAD(int fileFd, char* ptr, long size, long offset);

int FileItem_IsUpload(void* upload);
int Page_IsCache(void* cache);
void Page_GetKey(void* cache, int flags);


int SQLQry_InTransaction();
int SQLQry_CloseAll();
void SQLQry_Begin(void* res, const unsigned char* store);
void SQLQry_End(void* res);
void SQLQry_Rollback(void* res);
void SQLQry_Exec(void* async, void* sql, const unsigned char* qry, int native, long numValues);
void SQLQry_GetAsText(void* res, int qryKey,  long row, long col);
void SQLQry_GetAsInt(void* res, int qryKey,  long row, long col);
void SQLQry_GetAsBool(void* res, int qryKey,  long row, long col);
void SQLQry_GetColName(void* res, int qryKey, long col);
void SQLQry_Close(int qryKey);

void User_IsMobile(int* res);
int User_DefaultUID();
int User_DefaultGID();
int User_CurrentUID();
int User_CurrentGID();
int User_Logon();
void User_CurrentHash(void* res);
void User_Login(void* async, const char* name, const char* password, const char* hash, long expire);
void User_Logout();
void User_Update(long expire);
void User_SwapUID(void* async, int id);
void User_SwapGID(void* async, int id);
void User_CreateList(void* async, const void* pad, const void* data);
void User_DestroyList(const void* data);

void User_LastLogin(void* async, int id);
int User_LoginExpired(int id);
void User_SetCurrentData(long newValue);
void User_GetCurrentData(void* res);
void User_GetOwner(void* async, int id);
void User_GetGroupOwner(void* async, int id);
void User_SetOwner(void* async, int id, int ownerUID, int ownerGID);
void User_SetGroupOwner(void* async, int id, int ownerUID, int ownerGID);

void User_Register(void* async, const char* name, const char* password, void* holder);
void User_Validate(void* async, const char* name, const char* ticket);
void User_Add(void* async, const char* name, const char* password, int active);
void User_Get(void* async, const char* name);
void User_GetById(void* async, int id);
void User_DelByName(void* async, const char* name);
void User_DelById(void* async, int id);
void User_SetPassword(void* async, int id, const char* password);
void User_SetActive(void* async, int id, int value);
void User_HasGroup(void* async, int id, int group);
void User_AddGroup(void* async, int id, int group);
void User_DelGroup(void* async, int id, int group);

void Group_Add(void* async, const char* cname, int active);
void Group_Get(void* async, const char* cname);
void Group_DelByName(void* async, const char* cname);
void Group_DelById(void* async, int id);
void Group_SetActive(void* async, int id, int value);

void Memory_GetUsed(long* res);
void Memory_GetMax(long* res);

void Mail_GetFrom(void* async, const char* cemail);
void Mail_SendText(void* async, void* mail, void* minfo);

void Cookie_Write(void* request, void* cookie, const char* namePtr, const char* value);
void Cookie_Remove(void* keySlot);
void Cookie_Update(void* keySlot, int expire, int noJs, int secureOnly);

int Redirect_Set(const char* cvalue, int local, int state);

void WebSocket_Close(unsigned int socket, int hard);
long WebSocket_GetData();
void WebSocket_SetData(long value);
int WebSocket_GetNotify();
void WebSocket_SetNotify(int value);
int WebSocket_GetDataMode();
void WebSocket_SetDataMode(int value);

int String_strcoll(const char* a, const char* b);
long String_len(const char* a);
const char* String_empty();
int String_beginsWith(const char* a, long lenA, const char* b, long lenB);

void Array_SetCount(void* array, long count);

void Blob_Create(void* async, void* info);

void HTTPClient_Send(void* async, void* http, const char* curl, const char* cbody, const void* info);
void HTTPClient_Connect(void* async, void* http, const char* curl);
void HTTPClient_Close(int conFd);

void Error_Assert(const char *msg);
void Error_Break();
void Error_InitPrint();
void Error_GetPrint(void* holder);

double Time_Since1970();
double Time_ToLocal(double time);

void InetAddr_ToString(void* async, struct sockaddr* addr);
