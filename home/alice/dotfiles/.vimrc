" Vim settings
:set autoindent

syntax enable
filetype plugin indent on
au BufRead,BufNewFile *.md set filetype=markdown

" Workflow

" Create formatted pomodoro on given line
function! AppendTimeInline(pomo_count, lnum, char_prefix, end_time)
  	let t = localtime()
    	let stamp = '- '. a:char_prefix . string(a:pomo_count) . ' ' . strftime('%H%M', t)

	if a:end_time > 0
		let stamp = stamp . ' ' . strftime('%H%M', t + 1500)
    		call system("tmux send-keys -t :.+ 'tmr 25' C-m")
	endif

	let stamp = stamp . ': ' 

        let line = getline(a:lnum)
	let updated = substitute(line, '\S\+', stamp . '\0', '')
	call setline(a:lnum, updated)
endfunction

" Call pomodoro formatter with relevent pomodoro data, pass formatting of
" high level pomodoro headers
function! PullContent(char_prefix, metric_char, end_time)

	" Mark position of latest pomodoro 
	:mark C

	" Get current line number and content
	let cur_line = line('.')
	let cont = getline(cur_line) 
	let i = cur_line - 1

	" Loop updwards in document until finding heading 3
	while i > 0
		let header_line = getline(i)

		" Check if line contains heading 3 prefix
		if stridx(header_line, '###') > -1 
			
			" Finds length between '[' and ']'
			let open_idx = stridx(header_line, '[')
			let close_idx = stridx(header_line, ']')

			" Gets pomodoro count based on difference
			let metric_count = close_idx - open_idx 
			let header_line = header_line[:open_idx] . a:metric_char . header_line[open_idx + 1:] 
			call setline(i, header_line)
			call AppendTimeInline(metric_count, cur_line, a:char_prefix, a:end_time)

			break
		endif

		let i -= 1
	endwhile
endfunction


function! SaveBackupWithTimestamp()
        let l:current_file = expand('%:p')

        if empty(l:current_file)
                echo "No file associated with current buffer"
                return
        endif

        write

        let l:file_dir = expand('%:p:h')
        let l:file_name = expand('%:t:r')
        let l:file_ext = expand('%:e')

        let l:timestamp = strftime('%Y%m%d_%H%M%S')

        let l:backup_dir = l:file_dir . '/' . l:file_name . '-backups'

        if !isdirectory(l:backup_dir)
                call mkdir(l:backup_dir, 'p')
        endif

        if empty(l:file_ext)
                let l:backup_file = l:backup_dir . '/' . l:file_name . '_' . l:timestamp
        else
                let l:backup_file = l:backup_dir . '/' . l:file_name . '_' . l:timestamp . '.' . l:file_ext
        endif

        execute 'write ' . fnameescape(l:backup_file)

        edit

        echo "Backup saved: " . l:backup_file
endfunction

function! CreatePomodoroTemplate()
	let text_content = ["---", "", "# " . strftime('%Y%m%d'), "",  "## tasks", ""]

	let cur_line = line('.')
	
	call append(cur_line, text_content)

endfunction

function! Scratch()
	execute "e ~/Documents/pkb/scratch/" . strftime('%Y-%m-%d') . ".md" 
	execute "w"
	execute "mark S"

endfunction


" Commands
command! Time call PullContent("P", "x", 1)
command! Lime call PullContent("L", "~", 0)
command! Sime call Scratch()

command! BackupWithTime call SaveBackupWithTimestamp()
cabbrev wb BackupWithTime

command! Pomtem call CreatePomodoroTemplate()
