" Vim indent file
" Language:	PL/SQL
" Author:	Geoff Evans
" Maintainer:	Bill Pribyl <bill@plnet.org>
" Last Change:	Tue Sep 17 13:31:00 CDT 2002
" URL:		http://plnet.org/files/vim/
" $Id: plsql.vim,v 1.2 2002/09/17 17:36:24 root Exp root $

" TODO
" 1. should not indent line following SQL statement containing 'is'
" 2. should unindent on 'begin' when it follows inline subprograms
"    (that is, subprograms implemented in the decl section)


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
setlocal indentkeys+==~then,=~exception,=~end,=~else,=~elsif,=~begin,=~when


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
  let lnumsave = lnum

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
    if line =~ '\(begin\|case\|if\|as\|is\|then\|when\|loop\|else\|elsif\|exception\|declare\)\>'
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
    if (cline =~ '^\s*\(then\|exception\|else\|elsif\|end\)\>' || line =~ '^\s*)')
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
    endif

  " Subtract shiftwidth on a when or end iff preceded by another when with no
  " intervening exception
    if cline =~ '^\s*\(when\|end\)\>'
       let lnum = lnumsave
       let line = getline(lnum)
       while (lnum >= 0)
          let line = getline(lnum)
          let lnum = lnum - 1
          if line =~ '\(exception\|case\)\>'
             break
          endif
          if line =~ '\(when\)\>'
             let ind = ind - &sw
             break
          endif
       endwhile
    endif

  return ind

endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:ts=8:sts=2:sw=2
