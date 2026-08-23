Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      "http://localhost:5173",
      "https://master-drinks-frontend.vercel.app",
      "https://barbuddy.itsjonathanatkins.com"
    )

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
