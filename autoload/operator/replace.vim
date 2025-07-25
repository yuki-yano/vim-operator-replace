" operator-replace - Operator to replace text with register content
" Version: 0.0.5
" Copyright (C) 2009-2015 Kana Natsuno <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! operator#replace#do(motion_wise)  "{{{2
  let visual_command = s:visual_command_from_wise_name(a:motion_wise)

  let put_command = (s:deletion_moves_the_cursor_p(
  \                    a:motion_wise,
  \                    getpos("']")[1:2],
  \                    len(getline("']")),
  \                    [line('$'), len(getline('$'))]
  \                  )
  \                  ? 'p'
  \                  : 'P')

  let original_virtualedit = &g:virtualedit
  let &g:virtualedit = ''
  if !s:is_empty_region(getpos("'["), getpos("']"))
    let original_selection = &g:selection
    let &g:selection = 'inclusive'

    let g:operator_replace_active = 1
    let g:operator_replace_start_pos = getpos("'[")
    let g:operator_replace_end_pos = getpos("']")

    execute 'normal' '`['.visual_command.'`]"_d'

    " Work around
    " When regtype is linewise and text object is entire buffer, remove
    " blank line after pasting
    if getregtype(operator#user#register()) ==# 'V' && getline(1, '$') == ['']
        let put_command .= '`[k"_dd'
    endif

    let &g:selection = original_selection
  end
  execute 'normal' '"'.operator#user#register().put_command

  let g:operator_replace_active = 0
  let &g:virtualedit = original_virtualedit
  return
endfunction








" Misc.  "{{{1
" s:deletion_moves_the_cursor_p(motion_wise)  "{{{2
function! s:deletion_moves_the_cursor_p(motion_wise,
\                                       motion_end_pos,
\                                       motion_end_last_col,
\                                       buffer_end_pos)
  let [buffer_end_line, buffer_end_col] = a:buffer_end_pos
  let [motion_end_line, motion_end_col] = a:motion_end_pos

  if a:motion_wise ==# 'char'
    return ((a:motion_end_last_col == motion_end_col)
    \       || (buffer_end_line == motion_end_line
    \           && buffer_end_col <= motion_end_col))
  elseif a:motion_wise ==# 'line'
    return buffer_end_line == motion_end_line
  elseif a:motion_wise ==# 'block'
    return 0
  else
    echoerr 'E2: Invalid wise name:' string(a:wise_name)
    return 0
  endif
endfunction








function! s:is_empty_region(begin, end)  "{{{2
  " Whenever 'operatorfunc' is called, '[ is always placed before '] even if
  " a backward motion is given to g@.  But there is the only one exception.
  " If an empty region is given to g@, '[ and '] are set to the same line, but
  " '[ is placed after '].
  return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction




function! s:visual_command_from_wise_name(wise_name)  "{{{2()
  if a:wise_name ==# 'char'
    return 'v'
  elseif a:wise_name ==# 'line'
    return 'V'
  elseif a:wise_name ==# 'block'
    return "\<C-v>"
  else
    echoerr 'E1: Invalid wise name:' string(a:wise_name)
    return 'v'  " fallback
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
