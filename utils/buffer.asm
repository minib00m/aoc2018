struc buffer
    .ptr: resq 1
    .size: resq 1
endstruc

%define BUFPTR(x) x + buffer.ptr
%define BUFSIZE(x) x + buffer.size
