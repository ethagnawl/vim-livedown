command! LivedownPreview :call s:LivedownPreview()
command! LivedownKill :call s:LivedownKill()
command! LivedownToggle :call s:LivedownToggle()

if !exists('g:livedown_autorun')
  let g:livedown_autorun = 0
endif

if !exists('g:livedown_open')
  let g:livedown_open = 1
endif

if !exists('g:livedown_port')
  let g:livedown_port = 1337
endif

function SetLivedownCommandGlobalVariable()
  let l:global_livedown = 'livedown'
  let l:local_livedown_legacy = expand('<sfile>:h') . '/../node_modules/.bin/livedown'
  let l:local_livedown_modern = expand('<sfile>:h') . '/../node_modules/bin/livedown'

  if executable(l:global_livedown)
    let g:livedown_command = l:global_livedown
  elseif executable(l:local_livedown_legacy)
    let g:livedown_command = l:local_livedown_legacy
  elseif executable(l:local_livedown_modern)
    let g:livedown_command = l:local_livedown_modern
  else
    let g:livedown_command = ''
  endif
endfunction

if !exists('g:livedown_command')
  call SetLivedownCommandGlobalVariable()
endif

function! s:LivedownBrowser()
  if g:livedown_browser == "chrome" && has('macunix')
    let l:browser = "'Google Chrome'"
  else
    let l:browser = g:livedown_browser
  endif

  return '"' . l:browser . '"'
endfunction

function! s:LivedownRun(command)
  if (g:livedown_command == '')
    echoerr 'Unable to find livedown executable.
\ You can install it using: npm install -g livedown'
    return 0
  endif

  let l:platform_command = has('win32') ?
    \ "start /B " . a:command :
    \ a:command . " &"
  let l:Func = has('nvim') ?
    \ function('jobstart') :
    \ function('system')

  silent! call l:Func(l:platform_command)
endfunction

function! s:LivedownPreview()
  let l:command = g:livedown_command . " start \"" . expand('%:p') . "\"" .
      \ (g:livedown_open ? " --open" : "") .
      \ " --port " . g:livedown_port .
      \ (exists("g:livedown_browser") ? " --browser " . s:LivedownBrowser() : "")

  call s:LivedownRun(command)
endfunction

function! s:LivedownKill()
  call s:LivedownRun(g:livedown_command . " stop --port " . g:livedown_port)
endfunction

function! s:LivedownToggle()
	if !exists('s:livedownPreviewFlag')
		call s:LivedownPreview() | let s:livedownPreviewFlag = 1
	else
		call s:LivedownKill() | unlet! s:livedownPreviewFlag
	endif
endfunction
