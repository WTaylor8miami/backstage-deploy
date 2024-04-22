# Use an official Node runtime as a parent image
FROM node:14-buster-slim

# Set the working directory
WORKDIR /app

# Copy package.json and yarn.lock files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 100000

# Copy the local code to the container's workspace
COPY . .

# Build the application
RUN yarn tsc
RUN yarn build

# Expose the port the app runs on
EXPOSE 7000

# Define the Docker container's behavior at runtime
CMD ["yarn", "start"]
