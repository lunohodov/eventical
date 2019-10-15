StaccatoBackend = Staccato.tracker(ENV["ANALYTICS_KEY"] || "", nil, ssl: true)

Analytics.backend = StaccatoBackend
