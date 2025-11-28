FROM node:12-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

EXPOSE 8080

COPY . .

CMD ["npm", "run", "dev"] 