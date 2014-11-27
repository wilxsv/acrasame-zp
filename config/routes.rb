Rails.application.routes.draw do

  resources :scr_bombeos

  resources :scr_cloracions

  resources :scr_det_contables

  resources :scr_cuentuas, :scr_estados, :scr_cat_actividads #:scr_transaccions, :scr_area_trabajos, :scr_marca_producs
  resources :scr_rols, :scr_cargos, :scr_localidads, :scr_organizacions, :scr_usuarios, :scr_bancos, :scr_cat_organizacions#, :transacx
  resources :scr_empleados, :scr_periodo_representantes, :scr_representante_legals, :scr_usuario_rols, :scr_lecturas
  resources :scr_consumos, :scr_det_facturas, :scr_cobros, :scr_cat_cobros, :scr_cat_rep_legals, :scr_proveedors
  post 'scr_det_facturas/pagar'
  post 'scr_det_facturas/cargo'
  get 'resumen/index'
  get 'informe/index'
  get 'informe/balance'
  post 'informe/balance'
  post 'scr_lecturas/set'
  get 'informe/general'
  post 'informe/general'
#  get 'persona/index'  get 'usuario/index'    get 'cargo/index'  get 'rol/index'  get 'afijo/index'  get 'bloque/index'
#  get 'area/index' get 'cuenta/index'    get 'localidad/index' get 'recibo/lectura'   get 'pago/index'  get 'control/index'  post 'recibo/lectura'  get 'cobro/index'
  get 'libro/index'
  get 'proveedor/index'
  get 'estado/index'
  post 'libro/index'
  post 'libro/mayor'
  get 'libro/mayor'
  get 'recibo/index'
  get 'recibo/imprimir'
  post 'recibo/imprimir'
  post 'recibo/genera'
  get 'transaccion/index'
  get 'transaccion/show'
  post 'transaccion/index'
  post 'transaccion/create'
  post 'scr_usuarios/rol'
  get 'core/index'
  get 'core/login'
  get 'core/configure'
  post 'core/pago'
  post 'core/correlativo'
  post 'core/configure'
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
