# add plugins to ion-cms
Rails.configuration.ion.plugins ||= []


Rails.configuration.ion.plugins << Ion::Plugin.new( name: 'dashboard',
                                                    roles: [],
                                                    icon: 'icon-home',
                                                    path: '/ion/dashboard' )

Rails.configuration.ion.plugins << Ion::Plugin.new( name: 'users',
                                                    roles: ['admin'],
                                                    icon: 'icon-group',
                                                    path: '/ion/users' )