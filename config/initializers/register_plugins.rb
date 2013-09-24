# add plugins to iox-cms
Rails.configuration.iox.plugins ||= []


Rails.configuration.iox.plugins << Iox::Plugin.new( name: 'dashboard',
                                                    roles: [],
                                                    icon: 'icon-home',
                                                    path: '/iox/dashboard' )

Rails.configuration.iox.plugins << Iox::Plugin.new( name: 'webpages',
                                                    roles: ['editor'],
                                                    icon: 'icon-globe',
                                                    path: '/iox/webpages' )

Rails.configuration.iox.plugins << Iox::Plugin.new( name: 'users',
                                                    roles: ['admin'],
                                                    icon: 'icon-group',
                                                    path: '/iox/users' )