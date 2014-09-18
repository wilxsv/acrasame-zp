Rails.application.routes.draw do
  resources :scr_usuario_rols

  resources :scr_lecturas

  resources :scr_consumos

  resources :scr_det_facturas

  resources :scr_cobros

  resources :scr_cat_cobros

  resources :scr_transaccions, :scr_cuentuas, :scr_cat_actividads, :scr_area_trabajos, :scr_marca_producs, :scr_proveedors, :scr_estados
  resources :scr_bancos, :scr_rols, :scr_cargos, :scr_localidads, :scr_organizacions, :scr_cat_organizacions, :transacx, :scr_usuarios
  resources :scr_empleados
  post 'scr_det_facturas/pagar'
  post 'scr_det_facturas/cargo'
  get 'resumen/index'
  get 'informe/index'
  get 'persona/index'
  get 'usuario/index'
  get 'estado/index'
  get 'cargo/index'
  get 'rol/index'
  get 'afijo/index'
  get 'bloque/index'
  get 'area/index'
  get 'cuenta/index'
  get 'proveedor/index'
  get 'localidad/index'
  get 'libro/index'
  post 'libro/index'
  post 'libro/mayor'
  get 'libro/mayor'
  get 'pago/index'
  get 'control/index'
  get 'recibo/index'
  get 'recibo/lectura'
  get 'recibo/imprimir'
  post 'recibo/lectura'
  get 'cobro/index'
  get 'transaccion/index'
  get 'transaccion/show'
  post 'transaccion/index'
  post 'transaccion/create'
  post 'scr_usuarios/rol'
  get 'core/index'
  get 'core/login'
  get 'core/autenticate'
  post 'core/autenticate'
  get 'home/index'
  get 'home/login'
  post 'home/login'
  get 'home/logout'
  get 'home/profile'
  root 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
