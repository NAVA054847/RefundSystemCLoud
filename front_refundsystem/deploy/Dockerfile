FROM node:22-alpine3.19 as build

WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build --production

FROM fholzer/nginx-brotli:v1.12.2

WORKDIR /etc/nginx
COPY deploy/nginx.conf /etc/nginx/nginx.conf

COPY --from=build /app/build/ /usr/share/nginx/html
EXPOSE 443
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]