" Vim indent file
" Language:	PL/SQL
" Author:	Geoff Evans
" Maintainer:	Bill Pribyl <bill@plnet.org>
" Last Change:	Mon June 10 09:27:43 CDT 2002
" URL:		http://plnet.org/files/vim/
" $Id: plsql.vim,v 1.1 2002/09/12 16:13:00 root Exp $


" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1


let s:cpo_save = &cpo
set cpo-=C

" Make comments that cover multiple lines have
" Asterisks at the beginning of each line
set comments=sr:/*,mb:*,ex:*/
set fo=croq


" Ignore case when matching
setlocal ignorecase


setlocal indentexpr=GetPlsqlIndent()


" For these words, reevaluate the line's indentation
" Tilde means ignore case
setlocal indentkeys+==~then,=~exception,=~end,=~else,=~elsif,=~begin


" Only define the function once.
if exists("*GetPlsqlIndent")
  finish
endif


function GetPlsqlIndent()

  " Get the line to be indented
  let cline = getline(v:lnum)

  " Get current syntax item at the line's first char
  let csynid = ''
  if b:indent_use_syntax
    let csynid = synIDattr(synID(v:lnum,1,0),"name")
  endif

  " Now get the indent of the previous line.

  " Find a non-blank line above the current line.
  let lnum = prevnonblank(v:lnum - 1)
  " Hit the start of the file, use zero indent.
  if lnum == 0
    return 0
  endif
  let line = getline(lnum)
  let ind = indent(lnum)

  " Indenting on the next line

  " Add a 'shiftwidth' after begin, if, as, is, then, when, loop, else, 
  " elsif, exception, declare
  " Skip if the line also contains the closure for the above
    if line =~ '\(begin\|if\|as\|is\|then\|when\|loop\|else\|elsif\|exception\|declare\)\>'
       if line !~ '\(end\)\>'
          let ind = ind + &sw
       endif
    endif

  " Add a 'shiftwidth' after a '(' if there is no ')' on the same line
    if line =~ '^\s*('
       if line !~ ')\s*$'
          let ind = ind + &sw
       endif
    endif


  " Outdenting on the current line as you type it

  " Subtract a 'shiftwidth' on a then, exception, end, else, elsif, or ')'
    if (cline =~ '^\s*\(then\|exception\|end\|else\|elsif\)\>' || line =~ '^\s*)')
       let ind = ind - &sw
    endif

  " Subtract a 'shiftwidth' on a begin iff preceded by an as, is, or declare
  " with no intervening begin
    if cline =~ '^\s*\(begin\)\>'
       while (lnum >= 0)
          let line = getline(lnum)
          let lnum = lnum - 1
          if line =~ '\(begin\)\>'
             break
          endif
          if line =~ '\(as\|is\|declare\)\>'
             let ind = ind - &sw
             break
          endif
       endwhile
       echo cline
    endif

  return ind

endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:ts=8:sts=2:sw=2
