package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
)

func main() {
	engine := gin.New()

	gin.SetMode(gin.DebugMode)

	engine.GET("/hello", func(c *gin.Context) {
		fmt.Println("hello world")
		c.JSON(200, gin.H{
			"message": "Hello, World!",
		})
	})

	engine.Run(":9999")
}
