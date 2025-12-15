:set autoindent

syntax enable
filetype plugin indent on
au BufRead,BufNewFile *.md set filetype=markdown

function! CallWebhook(content, discord_ip)
	call system("curl --header \"Content-Type: application/json\" --data '{\"content\": \"" . a:content  . "\"}'". a:discord_ip)
endfunction

function! AppendTimeInline(pomo_count, lnum)
  	let t = localtime()
    	let stamp = '- P' . string(a:pomo_count) . ' ' . strftime('%H%M', t) . ' ' . strftime('%H%M', t + 1500) . ': '
        let line = getline(a:lnum)
	let updated = substitute(line, '\S\+', stamp . '\0', '')
	call setline(a:lnum, updated)
    	call system("tmux send-keys -t :.+ './tmr.py 25' C-m")
endfunction

function! PullContent()
	let cur_line = line('.')
	let cont = getline(cur_line) 
	let i = cur_line - 1
	while i > 0
		let header_line = getline(i)

		if stridx(header_line, '###') > -1 
			let open_idx = stridx(header_line, '[')
			let close_idx = stridx(header_line, ']')
			let x_count = close_idx - open_idx 
			let header_line = header_line[:open_idx] . 'x' . header_line[open_idx + 1:] 
			
			call setline(i, header_line)
			call AppendTimeInline(x_count, cur_line)

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


command! Time call PullContent()
command! Webhook call CallWebhook()

command! BackupWithTime call SaveBackupWithTimestamp()
cabbrev wb BackupWithTime


