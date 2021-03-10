Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'welcome#index'

  post'edit/start_shift' => 'welcome#start_shift'
  post'edit/stop_shift' => 'welcome#stop_shift'
  post'edit/break_start' => 'welcome#start_break'
  post'edit/break_end' => 'welcome#end_break'


end
