(local ns (vim.api.nvim_create_namespace ""))
(var initialized false)
(var options nil)
(var defaults {:count 2
               :duration 100
               :color "white"
               :highlight "BlinkingLine"})

(fn insert_highlights []
  (vim.api.nvim_set_hl 0 "BlinkingLine" {:bg options.color}))

(fn blink_cursorline []
  (if initialized
    (let [winwidth (vim.api.nvim_win_get_width 0)
          start (vim.api.nvim_win_get_cursor 0)
          startx (- (. start 1) 1)
          on-fn (fn [] (if (vim.api.nvim_buf_is_valid 0)
                         (vim.api.nvim_buf_add_highlight 0 ns options.highlight startx 0 -1)))
          off-fn (fn [] (if (vim.api.nvim_buf_is_valid 0)
                          (vim.api.nvim_buf_clear_namespace 0 ns 0 -1)))]
      (on-fn)
      (vim.defer_fn off-fn options.duration)
      (for [i 2 (* 2 (- options.count 1)) 2]
        (let [delay1 (* i options.duration)
              delay2 (+ delay1 options.duration)]
          (vim.defer_fn on-fn delay1)
          (vim.defer_fn off-fn delay2))))
    (vim.notify "blinker.nvim is not initialized. Call the setup function")))

(fn setup [opts]
  ; Merge opts & defaults into our options
  (set options (vim.tbl_deep_extend :force {} defaults opts))

  ; Set up highlights
  (insert_highlights)

  ; Set up auto command to auto re-setup highlights when the colorscheme changes
  (vim.api.nvim_create_autocmd
    "ColorScheme"
    {:group (vim.api.nvim_create_augroup "BlinkerInitHighlight" {:clear true})
     :callback (fn [] ((. (require "blinker") :insert_highlights)))})

  ; And now we are setup
  (set initialized true))

{: setup
 : blink_cursorline
 : ns
 : initialized
 : insert_highlights
 : options}
