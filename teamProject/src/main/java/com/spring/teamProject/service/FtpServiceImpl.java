package com.spring.teamProject.service;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class FtpServiceImpl implements FtpService {

    private static final Logger logger = LoggerFactory.getLogger(FtpServiceImpl.class);

    @Value("${ftp.server.host}")
    private String host;
    @Value("${ftp.server.port}")
    private int port;
    @Value("${ftp.server.username}")
    private String username;
    @Value("${ftp.server.password}")
    private String password;
    @Value("${ftp.server.directory}")
    private String baseDirectory;

    @Override
    public boolean uploadFile(File localFile, String subDirectory, String remoteFileName) {
        FTPClient ftpClient = new FTPClient();
        try (FileInputStream fis = new FileInputStream(localFile)) {
            // 1. FTP 서버 연결 및 로그인
            ftpClient.connect(host, port);
            ftpClient.login(username, password);
            // FileZilla 등 외부 FTP 클라이언트에서는 정상 작동하나,
            // 애플리케이션 내에서 FTP 디렉토리 접근/변경에 실패하는 경우,
            // Active/Passive 모드 차이일 가능성이 높으므로 Passive 모드를 명시적으로 설정.
            ftpClient.enterLocalPassiveMode();
            logger.info("FTP 서버 연결 성공: {}", host);

            // 2. 파일 타입 설정 (바이너리 모드)
            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);

            // 3. 기본 디렉토리로 이동
            if (StringUtils.hasText(baseDirectory) && !ftpClient.changeWorkingDirectory(baseDirectory)) {
                logger.error("FTP 기본 디렉토리 변경 실패: {}", baseDirectory);
                return false;
            }
            logger.info("FTP 현재 작업 디렉토리: {}", ftpClient.printWorkingDirectory());

            // ? --- 여기가 핵심 수정 부분입니다 --- ?
            // 4. 하위 폴더 생성 및 이동
            if (StringUtils.hasText(subDirectory)) {
                // 4-1. 하위 폴더가 존재하는지 확인
                boolean dirExists = ftpClient.changeWorkingDirectory(subDirectory);
                if (!dirExists) {
                    // 4-2. 없으면 새로 생성
                    logger.info("'{}' 폴더가 없어 새로 생성합니다.", subDirectory);
                    if (ftpClient.makeDirectory(subDirectory)) {
                        // 4-3. 생성 후 다시 해당 폴더로 이동
                        ftpClient.changeWorkingDirectory(subDirectory);
                    } else {
                        logger.error("'{}' 폴더 생성에 실패했습니다.", subDirectory);
                        return false;
                    }
                }
                 logger.info("하위 폴더로 이동 완료: {}", ftpClient.printWorkingDirectory());
            }

            // 5. 파일 업로드
            boolean done = ftpClient.storeFile(remoteFileName, fis);
            if (done) {
                logger.info("FTP 파일 업로드 성공: {}", remoteFileName);
            } else {
                logger.error("FTP 파일 업로드 실패: {}", remoteFileName);
            }
            return done;

        } catch (IOException e) {
            logger.error("FTP 작업 중 오류 발생", e);
            return false;
        } finally {
            // 6. 연결 종료
            try {
                if (ftpClient.isConnected()) {
                    ftpClient.logout();
                    ftpClient.disconnect();
                    logger.info("FTP 서버 연결 종료.");
                }
            } catch (IOException ex) {
                logger.error("FTP 연결 종료 중 오류 발생", ex);
            }
        }
    }

    // ✨ --- [신규] FTP 파일 다운로드 로직 구현 --- ✨
    @Override
    public byte[] downloadFile(String subDirectory, String fileName) throws IOException {
        FTPClient ftpClient = new FTPClient();
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        try {
            ftpClient.connect(host, port);
            if (!ftpClient.login(username, password)) {
                throw new IOException("FTP 로그인 실패");
            }
            ftpClient.enterLocalPassiveMode();
            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);

            // 이동할 전체 경로 조합
            String remotePath = baseDirectory;
            if (StringUtils.hasText(subDirectory)) {
                remotePath += "/" + subDirectory;
            }
            
            if (!ftpClient.changeWorkingDirectory(remotePath)) {
                throw new IOException("FTP 디렉토리 이동 실패: " + remotePath);
            }

            // 파일을 ByteArrayOutputStream에 직접 다운로드
            boolean success = ftpClient.retrieveFile(fileName, outputStream);
            
            if (success) {
                logger.info("FTP 파일 다운로드 성공: {}/{}", remotePath, fileName);
                return outputStream.toByteArray();
            } else {
                throw new IOException("FTP 파일 다운로드 실패. 파일이 없거나 권한 문제일 수 있습니다.");
            }

        } catch (IOException e) {
            logger.error("FTP 다운로드 작업 중 오류 발생", e);
            throw e; // 예외를 다시 던져서 컨트롤러가 처리하도록 함
        } finally {
            try {
                if (ftpClient.isConnected()) {
                    ftpClient.logout();
                    ftpClient.disconnect();
                }
            } catch (IOException ex) {
                logger.error("FTP 연결 종료 중 오류 발생", ex);
            }
        }
    }
}
