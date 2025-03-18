
;+
; A class for iteratoring through an index file, in groups sharing a
; common ID (typically TIMESTAMP or SCAN) - one field in each line.
; When that field value changes, the current grouping is ended an the
; next grouping begins.
;
; @file_comments
; This iterator should work with the various types of indexes although
; it needs to be provided with the relevant rows base class so that
; the appropriate formating and location of the ID field can be known.
;
; @field line_block a pointer to an array of lines in the current
; group
; @field row_block a pointer to an array of row structures that are
; filled from line_block right before row_block is returned.
; @field block_size the current number of elements in line_block and
; row_block.
; @field format_string the row format string used to read one line
; into one row structure.
; @field idStart the location of the first character of the ID field.
; @field idLen the number of characters (length) in the ID field.
; @field next_id the next ID field value, the group corresponding to
; this value is returned by next.  Set to an empty string if there are
; no more groups (at end).
;
; @private_file
;-
PRO index_iterator__define
  compile_opt idl2, hidden

  indx_iter = {INDEX_ITERATOR, $
               line_block:ptr_new(), $
               row_block:ptr_new(), $
               block_size: 0L, $
               format_string:'', $
               idStart:0, $
               idLen:0, $
               next_id:'', $
               indexPath:'', $
               lun:0 $
              }
END

;+
; Class constructor
; 
; @param indexPath {in}{required}{type=string} The full path to the
; index file.
; @param rows_base_class {in}{required}{type=string} The class name to
; use when getting the row format string and the corresponding row
; structure, ID field start and ID field length.
;
; @private
;- 
FUNCTION INDEX_ITERATOR::init, indexPath, rows_base_class
  compile_opt idl2

                                ; sanity check
                                ; here - exists, simple file, readable
                                ; as used in context, the version,
                                ; etc, should have already been
                                ; checked and OK so not checked here
  indexOK = file_test(indexPath,/read,/regular)
  if not indexOK then begin
     message,'indexPath does not exist, is not readable, or is not a regular file',/info
     return,-1
  endif
  self.indexPath = indexPath
                                ; make the base class object without a
                                ; file name just to get the info from
                                ; it
  sectObj = obj_new(rows_base_class,'')
  self.format_string = sectObj->get_format_string()
  ; arbitrary initial size guess - size always doubles as needed
  ; shrinks to size necessary to hold one scan of lines during next
  ; operation - will often stay at that size once set.
  self.block_size = 1000L
  self.row_block = ptr_new(replicate(sectObj->get_row_info_strct(),self.block_size),/no_copy)
  self.line_block = ptr_new(replicate("",self.block_size),/no_copy)
  ; the name of the called functions needs to be generalized
  self.idStart = sectObj->get_id_start()
  self.idLen = sectObj->get_id_len()
  obj_destroy, sectObj
  self.next_id = ""
  self.lun = -1

  ; attempt to read indexPath
                                ; This is necessary because
                                ; self.lun would be passed in as a
                                ; copy, not by reference.
  openr, lun, indexPath, /get_lun
  self.lun = lun 

  ; skip to actual index rows
  line = ''
  section = '[rows]'
  while strtrim(line) ne section and eof(self.lun) ne 1 do begin
     readf, self.lun, line
  endwhile

  if strtrim(line) ne section then begin
     message,"Index file does not contain rows section marker: " + indexPath,/info
     free_lun, self.lun
     self.lun = -1
     return, 0
  endif

  ; skip ahead to first line without a leading #
  lineFound = 0
  while eof(self.lun) ne 1 do begin
     readf, self.lun, line
     if strmid(line,0,1) ne "#" then begin
        lineFound = 1
        break
     endif
  endwhile

  if lineFound then begin
     self.next_id = strmid(line, self.idStart, self.idLen)
     (*self.line_block)[0L] = line
  endif

  return, 1
END

;+
; Class destructor
; @private
;-
PRO INDEX_ITERATOR::cleanup
  compile_opt idl2, hidden

  if ptr_valid(self.row_block) then ptr_free, self.row_block
  if ptr_valid(self.line_block) then ptr_free, self.line_block
  if self.lun ge 0 then free_lun, self.lun

END

;+
; The value of the ID shared by the row group to be returned by the
; next call to next.  This is the empty string if there are no more
; groups (at the end of the index).
;
; @returns id string, "" at end, no more groups
; @private
;-
FUNCTION INDEX_ITERATOR::next_id
  compile_opt idl2

  return,self.next_id
END

;+
; Returns an array of row structures corresponding to all of the rows
; sequential rows sharing the next_id value when this called.  next_id
; may repeat in a subsequent group, but not the next group.
; Returns -1 if there are no more rows (at end).
;
; @returns array of row stuctures or -1 if there are no more groups.
; @private
;-
FUNCTION INDEX_ITERATOR::next
  compile_opt idl2

  if strlen(self->next_id()) eq 0 then return, -1

  ; parse more lines until the end of file is reached or the 
  ; timestamp changes

  ; first row is always loaded if it gets to here
  next_row = 1L
  this_id = self->next_id()
  line = ''

  while eof(self.lun) ne 1 do begin
     readf, self.lun, line
     self.next_id = strmid(line,self.idStart, self.idLen)
     if this_id ne self.next_id then begin
        ; there is no way to reach this line without there being at 
        ; least one row to parse
        ; decode the currentblock
        ; resize as appropriate
        self.block_size = next_row
        *self.line_block = (*self.line_block)[0:(self.block_size-1)]
        *self.row_block = (*self.row_block)[0:(self.block_size-1)]
        reads, *self.line_block, *self.row_block, format=self.format_string
        ; and now init the next block with the line that was just read
        (*self.line_block)[0L] = line
        ; and return it
        return, *self.row_block
     endif
     if next_row ge self.block_size then begin
        ; double the size of the buffers
        (*self.line_block) = [*self.line_block,replicate((*self.line_block)[0],self.block_size)]
        (*self.row_block) = [*self.row_block,replicate((*self.row_block)[0],self.block_size)]
        self.block_size = n_elements(*self.line_block)
     endif
     (*self.line_block)[next_row] = line
     next_row += 1L
  endwhile

                                ; if it gets here, the end of the file
                                ; has been reached, there must be some
                                ; rows to decode
  self.block_size = next_row
  *self.line_block = (*self.line_block)[0:(self.block_size-1)]
  *self.row_block = (*self.row_block)[0:(self.block_size-1)]
  reads, *self.line_block, *self.row_block, format=self.format_string
  
  ; make sure future calls to next return -1
  self.next_id = ""

  return, *self.row_block
END

;+
; Returns the path to the index file used at creation.
;-
FUNCTION INDEX_ITERATOR::get_name
  compile_opt idl2

  return,self.indexPath
END
