struc buffer
    .ptr: resq 1
    .size: resq 1
    .entry_sizeof: resq 1 ; bytes for each entry
endstruc

%define BUFPTR(x) x + buffer.ptr
%define BUFSIZE(x) x + buffer.size
%define BUFENTRYSIZEOF(x) x + buffer.entry_sizeof
