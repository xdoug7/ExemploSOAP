//
//  ViewController.m
//  ExemploSOAP
//
//  Created by Douglas on 3/20/13.
//  Copyright (c) 2013 Douglas Ferreira. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSMutableString *retornoSOAP;
    BOOL teveRetorno;
}

@end

@implementation ViewController
@synthesize grausTextField, temperaturaSegControl, resultadoLabel;

#pragma mark - Métodos Úteis
- (IBAction)calcularTemperatura:(UIButton *)sender{
    
    NSString *mensagemSOAP, *SOAPAction;
    if (temperaturaSegControl.selectedSegmentIndex) {
        mensagemSOAP = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                        "<soap12:Body>"
                        "<CelsiusToFahrenheit xmlns=\"http://tempuri.org/\">"
                        "<Celsius>"
                        "%@"
                        "</Celsius>"
                        "</CelsiusToFahrenheit>"
                        "</soap12:Body>"
                        "</soap12:Envelope>", grausTextField.text];
        SOAPAction = @"http://tempuri.org/CelsiusToFahrenheit";
    } else{
        mensagemSOAP = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                        "<soap12:Body>"
                        "<FahrenheitToCelsius xmlns=\"http://tempuri.org/\">"
                        "<Fahrenheit>"
                        "%@"
                        "</Fahrenheit>"
                        "</FahrenheitToCelsius >"
                        "</soap12:Body>"
                        "</soap12:Envelope>", grausTextField.text];
        SOAPAction = @"http://tempuri.org/FahrenheitToCelsius";
    }
    
    NSURL *url = [NSURL URLWithString:@"http://w3schools.com/webservices/tempconvert.asmx"];
    NSMutableURLRequest *requisicao = [NSMutableURLRequest requestWithURL:url];
    NSString *tamanhoMensagem = [NSString stringWithFormat:@"%d", [mensagemSOAP length]];
    
    [requisicao addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [requisicao addValue:SOAPAction forHTTPHeaderField:@"SOAPAction"];
    [requisicao addValue:tamanhoMensagem forHTTPHeaderField:@"Content-Length"];
    [requisicao setHTTPMethod:@"POST"];
    [requisicao setHTTPBody:[mensagemSOAP dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *conexao = [[NSURLConnection alloc] initWithRequest:requisicao delegate:self];
    
    if(conexao){
        webData = [NSMutableData data];
    }else{
        NSLog(@"Conexão nula. Não foi possível conectar.");
    }
}

#pragma mark - NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Erro com a conexão.");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"Pronto. Bytes recebidos: %d", [webData length]);
    NSString *xmlString = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", xmlString);
    if (xmlParser) {
        xmlParser = nil;
    }
    
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    [xmlParser setDelegate:self];
    [xmlParser shouldResolveExternalEntities];
    [xmlParser parse];    
}

#pragma mark - NSXMLParserDelegate

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"CelsiusToFahrenheitResult"] || [elementName isEqualToString:@"FahrenheitToCelsiusResult"] ) {
        if (!retornoSOAP) {
            retornoSOAP = [[NSMutableString alloc] init];
        }
        teveRetorno = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (teveRetorno) {
        [retornoSOAP appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"CelsiusToFahrenheitResult"] || [elementName isEqualToString:@"FahrenheitToCelsiusResult"] ) {
        resultadoLabel.text = retornoSOAP;
        retornoSOAP = nil;        
        teveRetorno = NO;
    }
}

#pragma mark - Ciclo de vida da View

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGrausTextField:nil];
    [self setTemperaturaSegControl:nil];
    [self setResultadoLabel:nil];
    [super viewDidUnload];
}
@end
